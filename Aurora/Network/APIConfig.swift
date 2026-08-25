//
//  APIConfig.swift
// Aurora
//
//  PRODUCTION API Configuration - AWS EC2 Backend
//  Base: https://desktop-p1p7892.taildbc5d3.ts.net
//

import Foundation

struct APIConfig {

    // MARK: - Base Configuration

    /// Production API base URL (LAN)
    static let productionBaseURL = "http://192.168.43.173:8001"

    /// Development/Staging base URL (LAN)
    static let developmentBaseURL = "http://192.168.43.173:8001"

    /// Current environment
    static var environment: Environment {
        #if DEBUG
            return .development
        #else
            return .production
        #endif
    }

    /// Active base URL based on environment or user settings
    static var apiBaseURL: String {
        if let customURL = UserDefaults.standard.string(forKey: "apiBaseURL"), !customURL.isEmpty {
            return customURL
        }

        switch environment {
        case .development:
            return developmentBaseURL
        case .production:
            return productionBaseURL
        }
    }

    /// WebSocket base URL (wss for https)
    static var wsBaseURL: String {
        // Check for custom bot endpoint first (which might be the full WS URL)
        if let customBotEndpoint = UserDefaults.standard.string(forKey: "botEndpoint"),
            !customBotEndpoint.isEmpty
        {
            // If it starts with ws:// or wss://, return it as is
            if customBotEndpoint.hasPrefix("ws://") || customBotEndpoint.hasPrefix("wss://") {
                return customBotEndpoint
            }
        }

        let base = apiBaseURL.replacingOccurrences(of: "/api", with: "")
        return base.replacingOccurrences(of: "https://", with: "wss://")
            .replacingOccurrences(of: "http://", with: "ws://")
    }

    // MARK: - Request Configuration

    /// Default request timeout (30 seconds)
    static let requestTimeout: TimeInterval = 30

    /// Upload/Download timeout (60 seconds)
    static let resourceTimeout: TimeInterval = 60

    /// WebSocket timeout (90 seconds)
    static let websocketTimeout: TimeInterval = 90

    /// Maximum retry attempts for failed requests
    static let maxRetries = 3

    /// Retry delay (seconds)
    static let retryDelay: TimeInterval = 2

    // MARK: - Headers

    /// Default HTTP headers
    static var defaultHeaders: [String: String] {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-Client-Version": appVersion,
            "X-Client-Platform": "iOS",
        ]
    }

    /// Authorization header with token
    static func authHeaders(token: String) -> [String: String] {
        var headers = defaultHeaders
        headers["Authorization"] = "Bearer \(token)"
        return headers
    }

    // MARK: - App Info

    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    // MARK: - Environment

    enum Environment {
        case development
        case production

        var name: String {
            switch self {
            case .development: return "Development"
            case .production: return "Production"
            }
        }
    }

    // MARK: - SSL/TLS Configuration

    /// Allow self-signed certificates in debug mode only
    static var allowSelfSignedCertificates: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }

    /// Trusted domains for certificate pinning
    static let trustedDomains = ["desktop-p1p7892.taildbc5d3.ts.net"]

    // MARK: - Cache Configuration

    /// Cache policy
    static let cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData

    /// Cache size (10 MB)
    static let cacheSize = 10 * 1024 * 1024

    // MARK: - Logging

    /// Enable request/response logging
    static var enableLogging: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }

    /// Log requests
    static func logRequest(_ request: URLRequest) {
        guard enableLogging else { return }

        print("🌐 API Request")
        print("   URL: \(request.url?.absoluteString ?? "N/A")")
        print("   Method: \(request.httpMethod ?? "N/A")")

        if let headers = request.allHTTPHeaderFields {
            print("   Headers: \(headers)")
        }

        if let body = request.httpBody,
            let bodyString = String(data: body, encoding: .utf8)
        {
            print("   Body: \(bodyString)")
        }
    }

    /// Log response
    static func logResponse(_ response: URLResponse?, data: Data?, error: Error?) {
        guard enableLogging else { return }

        if let error = error {
            print("❌ API Error: \(error.localizedDescription)")
            return
        }

        if let httpResponse = response as? HTTPURLResponse {
            let statusEmoji = (200...299).contains(httpResponse.statusCode) ? "✅" : "⚠️"
            print("\(statusEmoji) API Response")
            print("   Status: \(httpResponse.statusCode)")

            if let data = data,
                let responseString = String(data: data, encoding: .utf8)
            {
                print("   Data: \(responseString)")
            }
        }
    }
}
