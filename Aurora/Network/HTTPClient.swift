//
//  HTTPClient.swift
// Aurora
//
//  Unified HTTP client for all API requests with automatic auth handling
//

import Foundation

class HTTPClient {

    static let shared = HTTPClient()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfig.requestTimeout
        config.timeoutIntervalForResource = APIConfig.resourceTimeout
        config.requestCachePolicy = APIConfig.cachePolicy

        self.session = URLSession(
            configuration: config, delegate: SSLPinningDelegate(), delegateQueue: nil)

        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601

        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - GET Request

    func get<T: Decodable>(
        endpoint: String,
        queryParams: [String: String]? = nil,
        requiresAuth: Bool = false,
        retries: Int = 3
    ) async throws -> T {

        var urlString = endpoint

        if let params = queryParams, !params.isEmpty {
            let queryString = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            urlString += "?\(queryString)"
        }

        guard let url = URL(string: urlString) else {
            throw HTTPError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request = applyHeaders(to: request, requiresAuth: requiresAuth)

        APIConfig.logRequest(request)

        return try await executeRequest(request, retries: retries)
    }

    // MARK: - POST Request

    func post<T: Decodable>(
        endpoint: String,
        body: [String: Any]? = nil,
        requiresAuth: Bool = false,
        retries: Int = 3
    ) async throws -> T {

        guard let url = URL(string: endpoint) else {
            throw HTTPError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request = applyHeaders(to: request, requiresAuth: requiresAuth)

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        APIConfig.logRequest(request)

        return try await executeRequest(request, retries: retries)
    }

    func post<T: Decodable, E: Encodable>(
        endpoint: String,
        body: E,
        requiresAuth: Bool = false,
        retries: Int = 3
    ) async throws -> T {

        guard let url = URL(string: endpoint) else {
            throw HTTPError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request = applyHeaders(to: request, requiresAuth: requiresAuth)

        request.httpBody = try encoder.encode(body)

        APIConfig.logRequest(request)

        return try await executeRequest(request, retries: retries)
    }

    // MARK: - PUT Request

    func put<T: Decodable>(
        endpoint: String,
        body: [String: Any]? = nil,
        requiresAuth: Bool = false,
        retries: Int = 3
    ) async throws -> T {

        guard let url = URL(string: endpoint) else {
            throw HTTPError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request = applyHeaders(to: request, requiresAuth: requiresAuth)

        if let body = body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        }

        APIConfig.logRequest(request)

        return try await executeRequest(request, retries: retries)
    }

    // MARK: - DELETE Request

    func delete<T: Decodable>(
        endpoint: String,
        requiresAuth: Bool = false,
        retries: Int = 3
    ) async throws -> T {

        guard let url = URL(string: endpoint) else {
            throw HTTPError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request = applyHeaders(to: request, requiresAuth: requiresAuth)

        APIConfig.logRequest(request)

        return try await executeRequest(request, retries: retries)
    }

    // MARK: - Execute Request

    private func executeRequest<T: Decodable>(
        _ request: URLRequest,
        retries: Int
    ) async throws -> T {

        do {
            let (data, response) = try await session.data(for: request)

            APIConfig.logResponse(response, data: data, error: nil)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw HTTPError.invalidResponse
            }

            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success
                return try decoder.decode(T.self, from: data)

            case 401:
                // Unauthorized - token might be expired
                throw HTTPError.unauthorized

            case 403:
                // Forbidden
                throw HTTPError.forbidden

            case 404:
                // Not found
                throw HTTPError.notFound

            case 422:
                // Validation error
                if let errorResponse = try? decoder.decode(ValidationErrorResponse.self, from: data)
                {
                    throw HTTPError.validationError(errorResponse.errors)
                }
                throw HTTPError.serverError(httpResponse.statusCode, data)

            case 500...599:
                // Server error
                throw HTTPError.serverError(httpResponse.statusCode, data)

            default:
                throw HTTPError.unknown(httpResponse.statusCode)
            }

        } catch let error as HTTPError {
            // If unauthorized, try to refresh token
            if case .unauthorized = error, retries > 0 {
                await tryRefreshToken()
                return try await executeRequest(request, retries: retries - 1)
            }
            throw error

        } catch {
            // Network error - retry if possible
            if retries > 0 {
                try await Task.sleep(nanoseconds: UInt64(APIConfig.retryDelay * 1_000_000_000))
                return try await executeRequest(request, retries: retries - 1)
            }
            throw HTTPError.networkError(error)
        }
    }

    // MARK: - Headers

    private func applyHeaders(to request: URLRequest, requiresAuth: Bool) -> URLRequest {
        var request = request

        // Apply default headers
        for (key, value) in APIConfig.defaultHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Add authorization if required
        if requiresAuth {
            if let token = KeychainManager.shared.getAuthToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        return request
    }

    // MARK: - Token Refresh

    private func tryRefreshToken() async {
        // Delegate to AuthService
        // await AuthService.shared.refreshAuthToken()
        print("⚠️ Token refresh disabled in single-user mode")
    }
}

// MARK: - SSL Pinning Delegate

class SSLPinningDelegate: NSObject, URLSessionDelegate {

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {

        guard
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust
        else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        let host = challenge.protectionSpace.host

        // Allow trusted domains
        if APIConfig.trustedDomains.contains(host) {
            // In debug mode, allow self-signed certificates
            #if DEBUG
                if APIConfig.allowSelfSignedCertificates {
                    let credential = URLCredential(trust: serverTrust)
                    completionHandler(.useCredential, credential)
                    return
                }
            #endif
        }

        // Default handling for production
        completionHandler(.performDefaultHandling, nil)
    }
}

// MARK: - HTTP Errors

enum HTTPError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case validationError([String: [String]])
    case serverError(Int, Data)
    case networkError(Error)
    case decodingError(Error)
    case unknown(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized. Please sign in again."
        case .forbidden:
            return "Access forbidden"
        case .notFound:
            return "Resource not found"
        case .validationError(let errors):
            let messages = errors.values.flatMap { $0 }.joined(separator: ", ")
            return "Validation error: \(messages)"
        case .serverError(let code, let data):
            if let errorMessage = try? JSONDecoder().decode(HTTPErrorResponse.self, from: data) {
                return "Server error (\(code)): \(errorMessage.error)"
            }
            return "Server error: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .unknown(let code):
            return "Unknown error: HTTP \(code)"
        }
    }
}

// MARK: - Error Response Models

// MARK: - Error Response Models

nonisolated struct ValidationErrorResponse: Codable {
    let errors: [String: [String]]
}

nonisolated private struct HTTPErrorResponse: Codable {
    let error: String
}
