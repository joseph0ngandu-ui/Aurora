//
//  PerformanceService.swift
// Aurora
//
//  Service for performance analytics
//

import Foundation

class PerformanceService {

    static let shared = PerformanceService()

    private let httpClient = HTTPClient.shared

    private init() {}

    // MARK: - Performance Stats

    func getStats() async throws -> PerformanceStatsResponse {
        return try await httpClient.get(
            endpoint: APIEndpoints.Performance.stats,
            requiresAuth: true
        )
    }

    func getDailyStats(days: Int = 30) async throws -> [DailyStatsResponse] {
        return try await httpClient.get(
            endpoint: APIEndpoints.Performance.daily,
            queryParams: ["days": "\(days)"],
            requiresAuth: true
        )
    }

    func getEquityCurve(days: Int = 30) async throws -> EquityCurveResponse {
        return try await httpClient.get(
            endpoint: APIEndpoints.Performance.equity,
            queryParams: ["days": "\(days)"],
            requiresAuth: true
        )
    }

    func getMetrics() async throws -> MetricsResponse {
        return try await httpClient.get(
            endpoint: APIEndpoints.Performance.metrics,
            requiresAuth: true
        )
    }
}
