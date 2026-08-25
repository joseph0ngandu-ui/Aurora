//
//  TradingService.swift
// Aurora
//
//  Service for trading operations
//

import Foundation

class TradingService {

    static let shared = TradingService()

    private let httpClient = HTTPClient.shared

    private init() {}

    // MARK: - Positions

    func getOpenPositions() async throws -> [PositionResponse] {
        return try await httpClient.get(
            endpoint: APIEndpoints.Positions.open,
            requiresAuth: true
        )
    }

    func getAllPositions() async throws -> [PositionResponse] {
        return try await httpClient.get(
            endpoint: APIEndpoints.Positions.list,
            requiresAuth: true
        )
    }

    func getPosition(id: String) async throws -> PositionResponse {
        return try await httpClient.get(
            endpoint: APIEndpoints.Positions.byId(id),
            requiresAuth: true
        )
    }

    func closePosition(id: String) async throws {
        let _: GenericResponse = try await httpClient.post(
            endpoint: APIEndpoints.Positions.close(id),
            requiresAuth: true
        )
    }

    func closeAllPositions() async throws {
        let _: GenericResponse = try await httpClient.post(
            endpoint: APIEndpoints.Positions.closeAll,
            requiresAuth: true
        )
    }

    // MARK: - Trades

    func getOpenTrades() async throws -> [TradeResponse] {
        return try await httpClient.get(
            endpoint: APIEndpoints.Trades.open,
            requiresAuth: true
        )
    }

    func getClosedTrades(limit: Int? = nil) async throws -> [TradeResponse] {
        var params: [String: String]? = nil
        if let limit = limit {
            params = ["limit": "\(limit)"]
        }

        return try await httpClient.get(
            endpoint: APIEndpoints.Trades.closed,
            queryParams: params,
            requiresAuth: true
        )
    }

    func getTradeHistory(limit: Int? = nil) async throws -> [TradeResponse] {
        var params: [String: String]? = nil
        if let limit = limit {
            params = ["limit": "\(limit)"]
        }

        return try await httpClient.get(
            endpoint: APIEndpoints.Trades.history,
            queryParams: params,
            requiresAuth: true
        )
    }

    func getRecentTrades(days: Int = 7) async throws -> [TradeResponse] {
        return try await httpClient.get(
            endpoint: APIEndpoints.Trades.recent,
            queryParams: ["days": "\(days)"],
            requiresAuth: true
        )
    }

    func getTrade(id: String) async throws -> TradeResponse {
        return try await httpClient.get(
            endpoint: APIEndpoints.Trades.byId(id),
            requiresAuth: true
        )
    }

    func closeTrade(id: String) async throws {
        let _: GenericResponse = try await httpClient.post(
            endpoint: APIEndpoints.Trades.close(id),
            requiresAuth: true
        )
    }

    func modifyTrade(id: String, stopLoss: Double?, takeProfit: Double?) async throws {
        var body: [String: Any] = [:]
        if let sl = stopLoss { body["stop_loss"] = sl }
        if let tp = takeProfit { body["take_profit"] = tp }

        let _: GenericResponse = try await httpClient.put(
            endpoint: APIEndpoints.Trades.modify(id),
            body: body,
            requiresAuth: true
        )
    }

    // MARK: - Market Data

    func getAvailablePairs() async throws -> [String] {
        // Using Strategy.symbols endpoint which returns available symbols
        let response: [String] = try await httpClient.get(
            endpoint: APIEndpoints.Strategy.symbols,
            requiresAuth: true
        )
        return response
    }
}
