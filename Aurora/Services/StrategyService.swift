//
//  StrategyService.swift
// Aurora
//
//  Service for strategy management
//

import Foundation

class StrategyService {

    static let shared = StrategyService()

    private let httpClient = HTTPClient.shared

    private init() {}

    // MARK: - Strategy Operations

    func getAllStrategies() async throws -> [StrategyResponse] {
        return try await httpClient.get(
            endpoint: APIEndpoints.Strategies.list,
            requiresAuth: false
        )
    }

    func getActiveStrategies() async throws -> [StrategyResponse] {
        return try await httpClient.get(
            endpoint: APIEndpoints.Strategies.active,
            requiresAuth: false
        )
    }

    func getValidatedStrategies() async throws -> [StrategyResponse] {
        return try await httpClient.get(
            endpoint: APIEndpoints.Strategies.validated,
            requiresAuth: false
        )
    }

    func discoverStrategies() async throws -> [StrategyResponse] {
        return try await httpClient.get(
            endpoint: APIEndpoints.Strategies.discover,
            requiresAuth: false
        )
    }

    func getStrategy(id: String) async throws -> StrategyDetailResponse {
        return try await httpClient.get(
            endpoint: APIEndpoints.Strategies.byId(id),
            requiresAuth: false
        )
    }

    func toggleStrategy(id: String) async throws {
        let _: GenericResponse = try await httpClient.post(
            endpoint: APIEndpoints.Strategies.toggle(id),
            requiresAuth: true
        )
    }

    func backtestStrategy(id: String, params: BacktestParams) async throws -> BacktestResponse {
        return try await httpClient.post(
            endpoint: APIEndpoints.Strategies.backtest(id),
            body: params,
            requiresAuth: true
        )
    }
}

// MARK: - Response Models

struct StrategyResponse: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let category: String?
    let riskLevel: String?
    let isActive: Bool
    let isValidated: Bool
    let winRate: Double?
    let profitFactor: Double?
    let totalTrades: Int?
    let avgProfit: Double?
    let maxDrawdown: Double?
    let createdAt: String
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, category
        case riskLevel = "risk_level"
        case isActive = "is_active"
        case isValidated = "is_validated"
        case winRate = "win_rate"
        case profitFactor = "profit_factor"
        case totalTrades = "total_trades"
        case avgProfit = "avg_profit"
        case maxDrawdown = "max_drawdown"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct StrategyDetailResponse: Codable {
    let id: String
    let name: String
    let description: String?
    let category: String?
    let riskLevel: String?
    let isActive: Bool
    let isValidated: Bool
    let parameters: StrategyParameters?
    let performance: StrategyPerformance?
    let rules: StrategyRules?
    let createdAt: String
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, category
        case riskLevel = "risk_level"
        case isActive = "is_active"
        case isValidated = "is_validated"
        case parameters, performance, rules
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct StrategyParameters: Codable {
    let symbols: [String]?
    let timeframes: [String]?
    let indicators: [String]?
    let riskPerTrade: Double?
    let maxPositions: Int?

    enum CodingKeys: String, CodingKey {
        case symbols, timeframes, indicators
        case riskPerTrade = "risk_per_trade"
        case maxPositions = "max_positions"
    }
}

struct StrategyPerformance: Codable {
    let totalTrades: Int
    let winRate: Double
    let profitFactor: Double
    let avgProfit: Double
    let maxDrawdown: Double
    let sharpeRatio: Double?

    enum CodingKeys: String, CodingKey {
        case totalTrades = "total_trades"
        case winRate = "win_rate"
        case profitFactor = "profit_factor"
        case avgProfit = "avg_profit"
        case maxDrawdown = "max_drawdown"
        case sharpeRatio = "sharpe_ratio"
    }
}

struct StrategyRules: Codable {
    let entry: [String]?
    let exit: [String]?
    let riskManagement: [String]?

    enum CodingKeys: String, CodingKey {
        case entry, exit
        case riskManagement = "risk_management"
    }
}

struct BacktestParams: Codable {
    let startDate: String
    let endDate: String
    let initialBalance: Double?
    let symbols: [String]?
    let timeframe: String?

    enum CodingKeys: String, CodingKey {
        case startDate = "start_date"
        case endDate = "end_date"
        case initialBalance = "initial_balance"
        case symbols, timeframe
    }
}

struct BacktestResponse: Codable {
    let totalTrades: Int
    let winRate: Double
    let profitFactor: Double
    let netProfit: Double
    let maxDrawdown: Double
    let sharpeRatio: Double?
    let equityCurve: [EquityPoint]?
    let trades: [TradeResponse]?

    enum CodingKeys: String, CodingKey {
        case totalTrades = "total_trades"
        case winRate = "win_rate"
        case profitFactor = "profit_factor"
        case netProfit = "net_profit"
        case maxDrawdown = "max_drawdown"
        case sharpeRatio = "sharpe_ratio"
        case equityCurve = "equity_curve"
        case trades
    }
}
