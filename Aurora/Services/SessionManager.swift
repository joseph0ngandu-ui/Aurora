//
//  SessionManager.swift
// Aurora
//
//  Manages user authentication and session state
//

import Combine
import Foundation
import Security

class SessionManager: ObservableObject {
    static let shared = SessionManager()

    // MARK: - Published Properties
    @Published var isAuthenticated: Bool = false
    @Published var token: String? = nil {
        didSet {
            if let token = token {
                _ = KeychainManager.shared.saveAuthToken(token)
                isAuthenticated = true
            } else {
                _ = KeychainManager.shared.deleteAuthToken()
                isAuthenticated = false
            }
        }
    }
    @Published var currentUser: User? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Keychain Keys
    // Delegated to KeychainManager

    private init() {
        // SINGLE USER MODE: Always authenticated
        self.token = "single_user_mode_token"
        self.isAuthenticated = true
        self.currentUser = User(email: "admin@eden.com", username: "Admin")

        // Try to load token from keychain on init (legacy)
        if KeychainManager.shared.getAuthToken() != nil {
            // Legacy token exists but we ignore it in single-user mode
        }
    }

    // MARK: - Authentication Methods

    /// Login with email and password
    func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    {
        guard let url = URL(string: APIEndpoints.Auth.login) else {
            completion(.failure(SessionError.invalidURL))
            return
        }

        isLoading = true
        errorMessage = nil

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let body: [String: String] = [
            "email": email,
            "password": password,
        ]

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            isLoading = false
            completion(.failure(error))
            return
        }

        print("🔐 Attempting login to: \(url.absoluteString)")
        print("📧 Email: \(email)")

        // Use NetworkManager for SSL bypass
        let task = NetworkManager.shared.dataTask(with: request) {
            [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    print("❌ Login network error: \(error.localizedDescription)")
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    completion(.failure(SessionError.networkError(error.localizedDescription)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid response type")
                    self?.errorMessage = "Invalid response from server"
                    completion(.failure(SessionError.invalidResponse))
                    return
                }

                print("📡 Response status: \(httpResponse.statusCode)")

                guard let data = data else {
                    print("❌ No data received")
                    self?.errorMessage = "No data received from server"
                    completion(.failure(SessionError.invalidResponse))
                    return
                }

                // Log response body
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 Response body: \(responseString)")
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    // Try to parse error message
                    if let errorData = try? JSONDecoder().decode(
                        LoginErrorResponse.self, from: data)
                    {
                        print("❌ Login failed: \(errorData.detail ?? "Unknown error")")
                        let message =
                            errorData.detail
                            ?? "Login failed with status \(httpResponse.statusCode)"
                        self?.errorMessage = message
                        completion(.failure(SessionError.loginFailed(message)))
                    } else {
                        let message = "Login failed with status \(httpResponse.statusCode)"
                        self?.errorMessage = message
                        completion(.failure(SessionError.httpError(httpResponse.statusCode)))
                    }
                    return
                }

                // Try to decode login response
                do {
                    let response = try JSONDecoder().decode(LoginResponse.self, from: data)
                    print("✅ Login successful! Token received.")

                    // Store token
                    self?.token = response.access_token
                    _ = KeychainManager.shared.saveAuthToken(response.access_token)

                    // Store user info if available
                    self?.currentUser = User(email: email, username: nil)

                    completion(.success(()))
                } catch {
                    print("❌ Failed to decode response: \(error)")
                    self?.errorMessage = "Failed to decode server response"
                    completion(.failure(SessionError.invalidResponse))
                }
            }
        }

        task.resume()
    }

    /// Register new user
    func register(
        email: String, password: String, username: String?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: APIEndpoints.Auth.register) else {
            completion(.failure(SessionError.invalidURL))
            return
        }

        isLoading = true
        errorMessage = nil

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        var body: [String: String] = [
            "email": email,
            "password": password,
        ]

        if let username = username, !username.isEmpty {
            body["name"] = username
        }

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            isLoading = false
            completion(.failure(error))
            return
        }

        print("📝 Attempting registration to: \(url.absoluteString)")
        print("📧 Email: \(email)")

        // Use NetworkManager for SSL bypass
        let task = NetworkManager.shared.dataTask(with: request) {
            [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    print("❌ Registration network error: \(error.localizedDescription)")
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                    completion(.failure(SessionError.networkError(error.localizedDescription)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("❌ Invalid response type")
                    self?.errorMessage = "Invalid response from server"
                    completion(.failure(SessionError.invalidResponse))
                    return
                }

                print("📡 Response status: \(httpResponse.statusCode)")

                guard let data = data else {
                    print("❌ No data received")
                    self?.errorMessage = "No data received from server"
                    completion(.failure(SessionError.invalidResponse))
                    return
                }

                // Log response body
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📄 Response body: \(responseString)")
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    if let errorData = try? JSONDecoder().decode(
                        LoginErrorResponse.self, from: data)
                    {
                        print("❌ Registration failed: \(errorData.detail ?? "Unknown error")")
                        let message = errorData.detail ?? "Registration failed"
                        self?.errorMessage = message
                        completion(.failure(SessionError.registrationFailed(message)))
                    } else {
                        let message = "Registration failed with status \(httpResponse.statusCode)"
                        self?.errorMessage = message
                        completion(.failure(SessionError.httpError(httpResponse.statusCode)))
                    }
                    return
                }

                // Try to decode response
                do {
                    // First try to decode as LoginResponse (in case server changes behavior)
                    if let response = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                        print("✅ Registration successful! Token received directly.")
                        self?.token = response.access_token
                        _ = KeychainManager.shared.saveAuthToken(response.access_token)
                        self?.currentUser = User(email: email, username: username)
                        completion(.success(()))
                        return
                    }

                    // Fallback: Decode as RegistrationResponse and then Login
                    let _ = try JSONDecoder().decode(RegistrationResponse.self, from: data)
                    print("✅ Registration successful! Logging in now...")

                    // Auto-login
                    self?.login(email: email, password: password) { result in
                        switch result {
                        case .success:
                            // Update username if provided (since login might not return it)
                            if let username = username {
                                self?.currentUser = User(email: email, username: username)
                            }
                            completion(.success(()))
                        case .failure(let error):
                            print("⚠️ Registration succeeded but auto-login failed: \(error)")
                            completion(.failure(error))
                        }
                    }
                } catch {
                    print("❌ Failed to decode response: \(error)")
                    self?.errorMessage = "Failed to decode server response"
                    completion(.failure(SessionError.invalidResponse))
                }
            }
        }

        task.resume()
    }

    /// Logout current user
    func logout() {
        token = nil
        currentUser = nil
        isAuthenticated = false
        errorMessage = nil

        // Clear token from Keychain
        _ = KeychainManager.shared.deleteAuthToken()

        print("👋 User logged out")
    }
}

// MARK: - Models

// MARK: - Errors

enum SessionError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case loginFailed(String)
    case registrationFailed(String)
    case networkError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP Error: \(code)"
        case .loginFailed(let message):
            return message
        case .registrationFailed(let message):
            return message
        case .networkError(let message):
            return message
        }
    }
}
