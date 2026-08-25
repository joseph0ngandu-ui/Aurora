//
//  KeychainManager.swift
// Aurora
//
//  Secure token storage using iOS Keychain
//

import Foundation
import Security

class KeychainManager {
    
    static let shared = KeychainManager()
    
    private init() {}
    
    // MARK: - Keys
    
    private enum Keys {
        static let authToken = "com.eden.authToken"
        static let refreshToken = "com.eden.refreshToken"
        static let userEmail = "com.eden.userEmail"
        static let userId = "com.eden.userId"
    }
    
    // MARK: - Save
    
    func saveAuthToken(_ token: String) -> Bool {
        return save(key: Keys.authToken, value: token)
    }
    
    func saveRefreshToken(_ token: String) -> Bool {
        return save(key: Keys.refreshToken, value: token)
    }
    
    func saveUserEmail(_ email: String) -> Bool {
        return save(key: Keys.userEmail, value: email)
    }
    
    func saveUserId(_ id: String) -> Bool {
        return save(key: Keys.userId, value: id)
    }
    
    // MARK: - Retrieve
    
    func getAuthToken() -> String? {
        return retrieve(key: Keys.authToken)
    }
    
    func getRefreshToken() -> String? {
        return retrieve(key: Keys.refreshToken)
    }
    
    func getUserEmail() -> String? {
        return retrieve(key: Keys.userEmail)
    }
    
    func getUserId() -> String? {
        return retrieve(key: Keys.userId)
    }
    
    // MARK: - Delete
    
    func deleteAuthToken() -> Bool {
        return delete(key: Keys.authToken)
    }
    
    func deleteRefreshToken() -> Bool {
        return delete(key: Keys.refreshToken)
    }
    
    func deleteUserEmail() -> Bool {
        return delete(key: Keys.userEmail)
    }
    
    func deleteUserId() -> Bool {
        return delete(key: Keys.userId)
    }
    
    // MARK: - Clear All
    
    func clearAll() {
        _ = deleteAuthToken()
        _ = deleteRefreshToken()
        _ = deleteUserEmail()
        _ = deleteUserId()
    }
    
    // MARK: - Private Helpers
    
    private func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        // Delete existing
        _ = delete(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("✅ Keychain: Saved \(key)")
            return true
        } else {
            print("❌ Keychain: Failed to save \(key) - Status: \(status)")
            return false
        }
    }
    
    private func retrieve(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess,
           let data = result as? Data,
           let value = String(data: data, encoding: .utf8) {
            return value
        }
        
        if status != errSecItemNotFound {
            print("⚠️ Keychain: Failed to retrieve \(key) - Status: \(status)")
        }
        
        return nil
    }
    
    private func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess || status == errSecItemNotFound {
            return true
        } else {
            print("⚠️ Keychain: Failed to delete \(key) - Status: \(status)")
            return false
        }
    }
}
