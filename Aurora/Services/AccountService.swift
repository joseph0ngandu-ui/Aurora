//
//  AccountService.swift
// Aurora
//
//  Service for account and balance management
//

import Foundation

class AccountService {

    static let shared = AccountService()

    private let httpClient = HTTPClient.shared

    private init() {}

    // MARK: - Account Info

    func getInfo() async throws -> AccountInfoResponse {
        return try await httpClient.get(
            endpoint: APIEndpoints.Account.info,
            requiresAuth: false
        )
    }

    func getBalance() async throws -> Double {
        let response: BalanceResponse = try await httpClient.get(
            endpoint: APIEndpoints.Account.balance,
            requiresAuth: false
        )
        return response.balance
    }

    func getHistory(days: Int = 30) async throws -> [AccountHistoryResponse] {
        return try await httpClient.get(
            endpoint: APIEndpoints.Account.history,
            queryParams: ["days": "\(days)"],
            requiresAuth: false
        )
    }

    // MARK: - MT5 Accounts

    func getMT5Accounts() async throws -> [MT5AccountResponse] {
        return try await httpClient.get(
            endpoint: APIEndpoints.Account.mt5List,
            requiresAuth: true
        )
    }

    func getPrimaryMT5Account() async throws -> MT5AccountResponse {
        return try await httpClient.get(
            endpoint: APIEndpoints.Account.mt5Primary,
            requiresAuth: true
        )
    }

    func createMT5Account(_ account: MT5AccountCreate) async throws -> MT5AccountResponse {
        return try await httpClient.post(
            endpoint: APIEndpoints.Account.mt5Create,
            body: account,
            requiresAuth: true
        )
    }

    func updateMT5Account(id: Int, account: MT5AccountUpdate) async throws -> MT5AccountResponse {
        return try await httpClient.put(
            endpoint: APIEndpoints.Account.mt5Update(id: id),
            body: try account.toDictionary(),
            requiresAuth: true
        )
    }

    func deleteMT5Account(id: Int) async throws {
        let _: GenericResponse = try await httpClient.delete(
            endpoint: APIEndpoints.Account.mt5Delete(id: id),
            requiresAuth: true
        )
    }
}

// MARK: - Response Models

struct AccountInfoResponse: Codable {
    let accountNumber: String
    let accountName: String
    let broker: String
    let server: String
    let currency: String
    let leverage: Int
    let balance: Double
    let equity: Double
    let margin: Double
    let freeMargin: Double
    let marginLevel: Double?

    enum CodingKeys: String, CodingKey {
        case accountNumber = "account_number"
        case accountName = "account_name"
        case broker, server, currency, leverage
        case balance, equity, margin
        case freeMargin = "free_margin"
        case marginLevel = "margin_level"
    }
}

struct BalanceResponse: Codable {
    let balance: Double
    let equity: Double?
    let margin: Double?
    let freeMargin: Double?

    enum CodingKeys: String, CodingKey {
        case balance, equity, margin
        case freeMargin = "free_margin"
    }
}

struct AccountHistoryResponse: Codable, Identifiable {
    let id: String
    let date: String
    let type: String
    let amount: Double
    let balance: Double
    let description: String?
}

struct MT5AccountResponse: Codable, Identifiable {
    let id: Int
    let accountNumber: String
    let accountName: String
    let broker: String
    let server: String
    let isPrimary: Bool
    let isActive: Bool
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case accountNumber = "account_number"
        case accountName = "account_name"
        case broker, server
        case isPrimary = "is_primary"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - MT5 Account Request Models
// Note: These are simplified versions for AccountService
// MT5AccountService has more complete versions with additional fields

struct MT5AccountCreate: Codable {
    let accountNumber: String
    let accountName: String
    let broker: String
    let server: String
    let password: String
    let isPrimary: Bool?

    enum CodingKeys: String, CodingKey {
        case accountNumber = "account_number"
        case accountName = "account_name"
        case broker, server, password
        case isPrimary = "is_primary"
    }
}

struct MT5AccountUpdate: Codable {
    let accountName: String?
    let password: String?
    let isPrimary: Bool?
    let isActive: Bool?

    enum CodingKeys: String, CodingKey {
        case accountName = "account_name"
        case password
        case isPrimary = "is_primary"
        case isActive = "is_active"
    }

    func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    }
}
