//
//  WebSocketManager.swift
//  Aurora
//
//  Manages WebSocket connections for real-time updates.
//  Handles authentication and message dispatching.
//

import Combine
import Foundation

class WebSocketManager: ObservableObject {
    static let shared = WebSocketManager()

    // MARK: - Properties

    private var webSocketTask: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)
    private var isConnected = false
    private var pingTimer: Timer?

    // Callbacks
    var onBotStatusUpdate: ((BotStatusUpdate) -> Void)?
    var onTradeUpdate: ((TradeUpdate) -> Void)?
    var onPositionUpdate: ((PositionUpdate) -> Void)?
    var onBalanceUpdate: ((BalanceUpdate) -> Void)?
    var onError: ((String) -> Void)?

    // MARK: - Init

    private init() {}

    // MARK: - Connection

    func connect() {
        connect(withToken: nil)
    }

    func connectWithAuth() {
        if let token = KeychainManager.shared.getAuthToken() {
            connect(withToken: token)
        } else {
            print("⚠️ WebSocket: No auth token available, connecting without auth")
            connect(withToken: nil)
        }
    }

    private func connect(withToken token: String?) {
        guard !isConnected else { return }

        guard let url = URL(string: APIEndpoints.WebSocket.notifications) else {
            print("❌ WebSocket: Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()

        isConnected = true
        print("🔌 WebSocket: Connecting to \(url.absoluteString)")

        receiveMessage()
        startPing()
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
        stopPing()
        print("🔌 WebSocket: Disconnected")
    }

    // MARK: - Message Handling

    private func receiveMessage() {
        guard isConnected else { return }

        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    self.handleMessage(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.handleMessage(text)
                    }
                @unknown default:
                    break
                }

                // Continue receiving messages
                self.receiveMessage()

            case .failure(let error):
                print("❌ WebSocket Error: \(error.localizedDescription)")
                self.isConnected = false
                self.onError?(error.localizedDescription)
                // Attempt reconnect after delay? For now, just stop.
                self.stopPing()
            }
        }
    }

    private func handleMessage(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            // Try decoding as Envelope first
            if let envelope = try? decoder.decode(WebSocketMessageEnvelope.self, from: data) {
                handleEnvelope(envelope)
            } else {
                // Fallback: Try decoding directly (legacy or simple format)
                // This part is tricky without knowing exact format if not envelope
                // But based on Models_Complete, we expect an envelope.
                print("⚠️ WebSocket: Received unknown message format: \(text)")
            }
        }
    }

    private func handleEnvelope(_ envelope: WebSocketMessageEnvelope) {
        guard let data = envelope.data.data(using: .utf8) else { return }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            switch envelope.type {
            case "bot_status":
                let update = try decoder.decode(BotStatusUpdate.self, from: data)
                DispatchQueue.main.async { self.onBotStatusUpdate?(update) }

            case "trade_update", "trade":
                let update = try decoder.decode(TradeUpdate.self, from: data)
                DispatchQueue.main.async { self.onTradeUpdate?(update) }

            case "position_update", "position":
                let update = try decoder.decode(PositionUpdate.self, from: data)
                DispatchQueue.main.async { self.onPositionUpdate?(update) }

            case "balance_update", "balance":
                let update = try decoder.decode(BalanceUpdate.self, from: data)
                DispatchQueue.main.async { self.onBalanceUpdate?(update) }

            case "error":
                print("❌ WebSocket Server Error: \(envelope.error ?? "Unknown")")
                DispatchQueue.main.async { self.onError?(envelope.error ?? "Unknown server error") }

            default:
                print("⚠️ WebSocket: Unknown message type: \(envelope.type)")
            }
        } catch {
            print("❌ WebSocket Decoding Error for type \(envelope.type): \(error)")
        }
    }

    // MARK: - Ping/Pong

    private func startPing() {
        stopPing()
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }

    private func stopPing() {
        pingTimer?.invalidate()
        pingTimer = nil
    }

    private func sendPing() {
        guard isConnected else { return }
        webSocketTask?.sendPing { error in
            if let error = error {
                print("❌ WebSocket Ping Failed: \(error)")
                self.disconnect()
            }
        }
    }
}
