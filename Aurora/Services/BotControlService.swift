//
//  BotControlService.swift
// Aurora
//
//  Service for bot control operations
//

import Combine
import Foundation

class BotControlService {

    static let shared = BotControlService()
    @Published var botStatus: BotStatusResponse?
    @Published var botConfig: BotConfigResponse?
    private let httpClient = HTTPClient.shared

    private init() {}

    // MARK: - Bot Status

    func getStatus() async throws -> BotStatusResponse {
        return try await httpClient.get(
            endpoint: APIEndpoints.Bot.status,
            requiresAuth: true
        )
    }

    func getHealth() async throws -> HealthResponse {
        return try await httpClient.get(
            endpoint: APIEndpoints.Bot.health,
            requiresAuth: true
        )
    }

    // MARK: - Bot Control

    func start() async throws {
        let _: GenericResponse = try await httpClient.post(
            endpoint: APIEndpoints.Bot.start,
            requiresAuth: true
        )
    }

    func stop() async throws {
        let _: GenericResponse = try await httpClient.post(
            endpoint: APIEndpoints.Bot.stop,
            requiresAuth: true
        )
    }

    func pause() async throws {
        let _: GenericResponse = try await httpClient.post(
            endpoint: APIEndpoints.Bot.pause,
            requiresAuth: true
        )
    }

    func resume() async throws {
        let _: GenericResponse = try await httpClient.post(
            endpoint: APIEndpoints.Bot.resume,
            requiresAuth: true
        )
    }

    // MARK: - Configuration

    func getConfig() async throws -> BotConfigResponse {
        return try await httpClient.get(
            endpoint: APIEndpoints.Bot.config,
            requiresAuth: true
        )
    }
    // MARK: - Convenience Methods
    func fetchStatus() async throws {
        self.botStatus = try await getStatus()
    }

    func fetchConfig() async throws {
        self.botConfig = try await getConfig()
    }

    func updateConfig(_ config: BotConfigUpdate) async throws {
        let _: GenericResponse = try await httpClient.put(
            endpoint: APIEndpoints.Bot.updateConfig,
            body: try config.toDictionary(),
            requiresAuth: true
        )
    }
}
