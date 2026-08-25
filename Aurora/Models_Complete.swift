//
//  Models_Complete.swift
// Aurora
//
//  COMPLETE data models for the Eden trading bot app
//  This file contains ALL required types for the entire app
//

import Combine
import Foundation

// MARK: - Position Models

/// Represents an active trading position (UI Model)
struct Position: Identifiable, Codable {
    var id = UUID()
    let symbol: String
    let direction: String  // "LONG" or "SHORT"
    let entry: Double
    let current: Double
    let pnl: Double
    let confidence: Double  // 0.0 to 1.0
    let bars: Int

    enum CodingKeys: String, CodingKey {
        case symbol, direction, entry, current, pnl, confidence, bars
    }
}

/// API Response for positions
struct PositionResponse: Codable, Identifiable {
    let id: String
    let ticket: String?
    let symbol: String
    let type: String
    let volume: Double
    let openPrice: Double
    var currentPrice: Double?
    let stopLoss: Double?
    let takeProfit: Double?
    var profit: Double?
    let swap: Double?
    let commission: Double?
    let openTime: String
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case id, ticket, symbol, type, volume
        case openPrice = "open_price"
        case currentPrice = "current_price"
        case stopLoss = "stop_loss"
        case takeProfit = "take_profit"
        case profit, swap, commission
        case openTime = "open_time"
        case comment
    }
}

// MARK: - Mapping from API to UI
// Note: toUIModel() extensions are defined in Models+Extensions.swift

// MARK: - Trade Models

/// Represents a completed trade (UI Model)
struct Trade: Identifiable, Codable {
    var id = UUID()
    let symbol: String
    let pnl: Double
    let time: String
    let rValue: Double  // R-multiple

    enum CodingKeys: String, CodingKey {
        case symbol, pnl, time, rValue
    }
}

/// API Response for trades
struct TradeResponse: Codable, Identifiable {
    let id: String
    let ticket: String?
    let symbol: String
    let type: String
    let volume: Double
    let openPrice: Double
    let closePrice: Double?
    let stopLoss: Double?
    let takeProfit: Double?
    let profit: Double?
    let commission: Double?
    let swap: Double?
    let openTime: String
    let closeTime: String?
    let duration: Double?
    let comment: String?
    let rMultiple: Double?

    enum CodingKeys: String, CodingKey {
        case id, ticket, symbol, type, volume
        case openPrice = "open_price"
        case closePrice = "close_price"
        case stopLoss = "stop_loss"
        case takeProfit = "take_profit"
        case profit, commission, swap
        case openTime = "open_time"
        case closeTime = "close_time"
        case duration, comment
        case rMultiple = "r_multiple"
    }
}

// MARK: - Equity Curve Models

/// Represents a data point on the equity curve (UI Model & API Response)
struct EquityPoint: Identifiable, Codable {
    var id = UUID()
    let time: String
    let value: Double
    let equity: Double?
    let drawdown: Double?

    enum CodingKeys: String, CodingKey {
        case time
        case value
        case equity
        case drawdown
    }
}

/// API Response for full equity curve
struct EquityCurveResponse: Codable {
    let equityCurve: [EquityPoint]
    let startBalance: Double?
    let endBalance: Double?
    let peakBalance: Double?
    let maxDrawdown: Double?

    enum CodingKeys: String, CodingKey {
        case equityCurve = "equity_curve"
        case startBalance = "start_balance"
        case endBalance = "end_balance"
        case peakBalance = "peak_balance"
        case maxDrawdown = "max_drawdown"
    }
}

// MARK: - Bot Status Models

/// Bot status information from API (Simple UI Model)
struct BotStatus: Codable {
    let isRunning: Bool
    let balance: Double
    let dailyPnL: Double
    let activePositions: Int
    let winRate: Double
    let riskTier: String
    let totalTrades: Int?
    let profitFactor: Double?
    let peakBalance: Double?
    let currentDrawdown: Double?
    // No CodingKeys needed - HTTPClient uses .convertFromSnakeCase
}

/// Complete API Response for bot status
struct BotStatusResponse: Codable {
    let isRunning: Bool
    let balance: Double
    let dailyPnl: Double
    let activePositions: Int
    let winRate: Double
    let riskTier: String
    let totalTrades: Int
    let profitFactor: Double
    let peakBalance: Double
    let currentDrawdown: Double
    let lastUpdate: String?
}

// MARK: - Bot Control Service Models

struct HealthResponse: Codable {
    let status: String
    let uptime: Double?
    let connections: HealthConnections?
}

struct HealthConnections: Codable {
    let mt5: Bool?
    let database: Bool?
    let websocket: Bool?
}

struct BotConfigResponse: Codable {
    let riskPerTrade: Double
    let maxPositions: Int
    let symbols: [String]
    let timeframes: [String]
    let strategy: String?

    enum CodingKeys: String, CodingKey {
        case riskPerTrade = "risk_per_trade"
        case maxPositions = "max_positions"
        case symbols, timeframes, strategy
    }
}

struct BotConfigUpdate: Codable {
    let riskPerTrade: Double?
    let maxPositions: Int?
    let symbols: [String]?
    let timeframes: [String]?
    let strategy: String?

    enum CodingKeys: String, CodingKey {
        case riskPerTrade = "risk_per_trade"
        case maxPositions = "max_positions"
        case symbols, timeframes, strategy
    }

    func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
    }
}

// MARK: - Performance Service Models

struct PerformanceStatsResponse: Codable {
    let totalTrades: Int
    let winningTrades: Int
    let losingTrades: Int
    let winRate: Double
    let profitFactor: Double
    let averageWin: Double
    let averageLoss: Double
    let largestWin: Double
    let largestLoss: Double
    let netProfit: Double?
    let grossProfit: Double?
    let grossLoss: Double?
    let sharpeRatio: Double?
    let sortinoRatio: Double?
    let maxDrawdown: Double
    let currentDrawdown: Double
    let maxDrawdownPercent: Double?
    let calmarRatio: Double?
    let recoveryFactor: Double?
    let profitPerTrade: Double?
    let periodStart: String?
    let periodEnd: String?
    let totalPnl: Double?
    let dailyPnl: Double?
    // No CodingKeys needed - HTTPClient uses .convertFromSnakeCase
}

struct DailyStatsResponse: Codable, Identifiable {
    let id = UUID()
    let date: String
    let trades: Int
    let wins: Int
    let losses: Int
    let pnl: Double
    let balance: Double
    let drawdown: Double?

    enum CodingKeys: String, CodingKey {
        case date, trades, wins, losses, pnl, balance, drawdown
    }
}

struct MetricsResponse: Codable {
    let winRate: Double
    let profitFactor: Double
    let sharpeRatio: Double?
    let maxDrawdown: Double
    let averageWin: Double
    let averageLoss: Double
    let expectancy: Double
    let riskRewardRatio: Double?

    enum CodingKeys: String, CodingKey {
        case winRate = "win_rate"
        case profitFactor = "profit_factor"
        case sharpeRatio = "sharpe_ratio"
        case maxDrawdown = "max_drawdown"
        case averageWin = "average_win"
        case averageLoss = "average_loss"
        case expectancy
        case riskRewardRatio = "risk_reward_ratio"
    }
}

// MARK: - Strategy Model

/// Trading strategy information
struct Strategy: Identifiable, Codable {
    let id: Int
    let name: String
    let description: String?
    let isActive: Bool
    let winRate: Double?
    let profitFactor: Double?
    let totalTrades: Int?
    let category: String?
    let riskLevel: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description
        case isActive = "is_active"
        case winRate = "win_rate"
        case profitFactor = "profit_factor"
        case totalTrades = "total_trades"
        case category
        case riskLevel = "risk_level"
        case createdAt = "created_at"
    }
}

// MARK: - Performance Metrics Model

/// Detailed performance analytics (UI Model)
struct PerformanceMetrics: Codable {
    let peakBalance: Double
    let currentDrawdown: Double
    let maxDrawdown: Double
    let totalTrades: Int
    let winningTrades: Int
    let losingTrades: Int
    let winRate: Double
    let profitFactor: Double
    let sharpeRatio: Double?
    let averageWin: Double
    let averageLoss: Double
    let largestWin: Double
    let largestLoss: Double
    let consecutiveWins: Int
    let consecutiveLosses: Int

    enum CodingKeys: String, CodingKey {
        case peakBalance = "peak_balance"
        case currentDrawdown = "current_drawdown"
        case maxDrawdown = "max_drawdown"
        case totalTrades = "total_trades"
        case winningTrades = "winning_trades"
        case losingTrades = "losing_trades"
        case winRate = "win_rate"
        case profitFactor = "profit_factor"
        case sharpeRatio = "sharpe_ratio"
        case averageWin = "average_win"
        case averageLoss = "average_loss"
        case largestWin = "largest_win"
        case largestLoss = "largest_loss"
        case consecutiveWins = "consecutive_wins"
        case consecutiveLosses = "consecutive_losses"
    }
}

// MARK: - MT5 Account Model

/// MT5 account display model
struct MT5Account: Identifiable {
    let id = UUID()
    let accountNumber: String
    let accountName: String
    let broker: String
    let server: String
    let isPrimary: Bool
    let isActive: Bool
}

// MARK: - WebSocket Message Models

/// WebSocket message envelope
struct WebSocketMessageEnvelope: Codable {
    let type: String
    let data: String  // JSON string
    let timestamp: String?
    let error: String?
}

/// Bot status update via WebSocket
struct BotStatusUpdate: Codable {
    let isRunning: Bool
    let state: String
    let balance: Double?
    let positions: Int?
    let timestamp: String

    enum CodingKeys: String, CodingKey {
        case isRunning = "is_running"
        case state, balance, positions, timestamp
    }
}

/// Trade update via WebSocket
struct TradeUpdate: Codable {
    let id: String
    let action: String  // "opened", "closed", "modified"
    let symbol: String
    let type: String
    let profit: Double?
    let timestamp: String
}

/// Position update via WebSocket
struct PositionUpdate: Codable {
    let id: String
    let symbol: String
    let profit: Double
    let currentPrice: Double
    let timestamp: String

    enum CodingKeys: String, CodingKey {
        case id, symbol, profit
        case currentPrice = "current_price"
        case timestamp
    }
}

/// Balance update via WebSocket
struct BalanceUpdate: Codable {
    let balance: Double
    let equity: Double?
    let margin: Double?
    let timestamp: String
}

// MARK: - User Models

/// User model (consolidated from all services)
struct User: Codable {
    let id: String?
    let email: String
    let name: String?
    let username: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, email, name, username
        case createdAt = "created_at"
    }

    // Convenience initializers for backward compatibility
    init(
        id: String? = nil, email: String, name: String? = nil, username: String? = nil,
        createdAt: String? = nil
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.username = username
        self.createdAt = createdAt
    }
}

/// Auth response models
struct AuthResponse: Codable {
    let token: String?
    let accessToken: String?
    let refreshToken: String?
    let expiresIn: Int?
    let user: User?
    let token_type: String?  // For backward compatibility with SessionManager

    enum CodingKeys: String, CodingKey {
        case token
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case user
        case token_type
    }

    // Computed property to get the actual token regardless of field name
    var actualToken: String {
        return token ?? accessToken ?? ""
    }
}

struct RegistrationResponse: Codable {
    let message: String
    let email: String
}

struct LoginResponse: Codable {
    let access_token: String
    let token_type: String
}

struct LoginErrorResponse: Codable {
    let detail: String?
}

struct TokenVerificationResponse: Codable {
    let valid: Bool
    let expiresAt: String?

    enum CodingKeys: String, CodingKey {
        case valid
        case expiresAt = "expires_at"
    }
}

// MARK: - Generic API Response Wrappers

/// Generic success response
struct SuccessResponse: Codable {
    let message: String
    let status: String?
}

/// Generic response (used by services)
struct GenericResponse: Codable {
    let message: String?
    let status: String?
    let success: Bool?
}

/// Generic error response
struct ErrorResponse: Codable {
    let error: String
    let details: String?
    let code: String?
}

// MARK: - Legacy WebSocket Messages (for backwards compatibility)

/// WebSocket message types
enum WebSocketMessageType: String, Codable {
    case positionUpdate = "position_update"
    case tradeExecuted = "trade_executed"
    case balanceUpdate = "balance_update"
    case botStatus = "bot_status"
    case error = "error"
}

/// WebSocket message wrapper (legacy)
struct WebSocketMessage: Codable {
    let type: WebSocketMessageType
    let data: String  // JSON string that needs to be decoded based on type
    let timestamp: String?
}
