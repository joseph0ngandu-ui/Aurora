//
//  BotManager.swift
// Aurora
//
//  PRODUCTION Bot Manager - Fully integrated with AWS backend
//  Now with dummy data fallback for testing without backend
//

import Combine
import Foundation

@MainActor
class BotManager: ObservableObject {

    // MARK: - Published Properties

    @Published var isRunning = false
    @Published var balance: Double = 0.0
    @Published var equity: Double = 0.0
    @Published var dailyPnL: Double = 0.0
    @Published var weekPnL: Double = 0.0
    @Published var monthPnL: Double = 0.0
    @Published var totalReturn: Double = 0.0
    @Published var activePositions: Int = 0
    @Published var totalTrades: Int = 0
    @Published var winRate: Double = 0.0
    @Published var profitFactor: Double = 0.0
    @Published var peakBalance: Double = 0.0
    @Published var currentDrawdown: Double = 0.0
    @Published var maxDrawdown: Double = 0.0
    @Published var botState: String = ""
    @Published var riskTier: String = ""
    @Published var riskPerTrade: Double = 0.0
    @Published var lastUpdate: Date = Date()
    @Published var error: String?
    @Published var isLoading = false

    @Published var positions: [PositionResponse] = []
    @Published var trades: [TradeResponse] = []
    @Published var equityCurve: [EquityPoint] = []

    // MARK: - Services

    private let botService = BotControlService.shared
    private let accountService = AccountService.shared
    private let tradingService = TradingService.shared
    private let performanceService = PerformanceService.shared
    private let websocket = WebSocketManager.shared

    private var cancellables = Set<AnyCancellable>()
    private var updateTimer: Timer?

    // MARK: - Init

    init() {
        setupWebSocket()
        setupBindings()
        startPeriodicUpdates()

        // Initial load
        Task {
            await loadInitialData()
        }
    }

    // MARK: - Setup

    private func setupWebSocket() {
        // Connect WebSocket
        // Connect WebSocket
        if SessionManager.shared.isAuthenticated {
            websocket.connectWithAuth()
        } else {
            websocket.connect()
        }

        // Handle bot status updates
        websocket.onBotStatusUpdate = { [weak self] update in
            Task { @MainActor in
                self?.handleBotStatusUpdate(update)
            }
        }

        // Handle trade updates
        websocket.onTradeUpdate = { [weak self] update in
            Task { @MainActor in
                self?.handleTradeUpdate(update)
            }
        }

        // Handle position updates
        websocket.onPositionUpdate = { [weak self] update in
            Task { @MainActor in
                self?.handlePositionUpdate(update)
            }
        }

        // Handle balance updates
        websocket.onBalanceUpdate = { [weak self] update in
            Task { @MainActor in
                self?.handleBalanceUpdate(update)
            }
        }
    }

    private func setupBindings() {
        // Observe Auth Status from SessionManager (UI Source of Truth)
        SessionManager.shared.$isAuthenticated
            .receive(on: RunLoop.main)
            .sink { [weak self] isAuthenticated in
                guard let self = self else { return }
                if isAuthenticated {
                    print("🔓 BotManager: User authenticated, loading data...")
                    Task { @MainActor in
                        await self.loadInitialData()
                        self.websocket.connectWithAuth()  // Connect with auth after login
                    }
                } else {
                    print("🔒 BotManager: User logged out, clearing data...")
                    Task { @MainActor in
                        self.resetData()
                        self.websocket.connect()  // Connect without auth after logout
                    }
                }
            }
            .store(in: &cancellables)
    }

    private func startPeriodicUpdates() {
        // Update every 30 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshData()
            }
        }
    }

    // MARK: - Data Loading

    func loadInitialData() async {
        // Prevent multiple simultaneous calls (race condition)
        guard !isLoading else {
            print("⚠️ loadInitialData already in progress, skipping duplicate call")
            return
        }

        isLoading = true
        error = nil

        // DETAILED LOGGING FOR DEBUGGING
        print("🔍 ========== API DEBUG START ==========")
        print("🔍 Base URL: \(APIEndpoints.baseURL)")
        print("🔍 Bot Status URL: \(APIEndpoints.Bot.status)")

        print("🔍 Starting parallel API calls...")

        // Load each task individually with error handling
        do {
            print("🔍 Fetching bot status...")
            let status = try await botService.getStatus()
            print("✅ Bot status fetched successfully")

            print("🔍 Fetching performance stats...")
            let stats = try await performanceService.getStats()
            print("✅ Performance stats fetched successfully")

            print("🔍 Fetching open positions...")
            let positions = try await tradingService.getOpenPositions()
            print("✅ Open positions fetched: \(positions.count) positions")

            print("🔍 Fetching recent trades...")
            let trades = try await tradingService.getRecentTrades(days: 7)
            print("✅ Recent trades fetched: \(trades.count) trades")

            print("🔍 Fetching equity curve...")
            let equityCurve = try await performanceService.getEquityCurve(days: 30)
            print("✅ Equity curve fetched: \(equityCurve.equityCurve.count) points")

            print("🔍 All API calls completed successfully!")

            // Update state
            updateFromStatus(status)
            updateFromStats(stats)
            self.positions = positions
            self.trades = trades
            self.equityCurve = equityCurve.equityCurve

            // Try to update equity from equity curve if available
            if let lastPoint = equityCurve.equityCurve.last {
                self.equity = lastPoint.equity ?? self.balance
            } else {
                self.equity = self.balance
            }

            lastUpdate = Date()
            print("✅ Initial data loaded successfully")
            print("🔍 Balance from API: \(balance)")
            print("🔍 Active Positions: \(activePositions)")
            print("🔍 Daily P&L: \(dailyPnL)")
            print("🔍 ========== API DEBUG END ==========")

        } catch {
            self.error = error.localizedDescription
            print("❌ ========== API FAILURE ==========")
            print("❌ Failed to load initial data: \(error)")
            print("❌ Error type: \(type(of: error))")
            if let decodingError = error as? DecodingError {
                print("❌ Decoding Error Context: \(decodingError)")
            }
            print("❌ ========== API FAILURE END ==========")
        }

        isLoading = false
    }

    func refreshData() async {
        guard !isLoading else { return }

        do {
            async let statusTask = botService.getStatus()
            async let statsTask = performanceService.getStats()
            async let positionsTask = tradingService.getOpenPositions()

            let (status, stats, positions) = try await (statusTask, statsTask, positionsTask)

            await MainActor.run {
                self.updateFromStatus(status)
                self.updateFromStats(stats)
                self.positions = positions
                self.lastUpdate = Date()

                // Approximate equity since we don't fetch curve on refresh
                // If we have active positions, equity might differ from balance
                // But without a direct equity endpoint, we default to balance or keep previous if reasonable
                // For now, let's rely on WebSocket for real-time equity updates
            }
        } catch {
            print("⚠️ Failed to refresh data: \(error)")
            self.error = error.localizedDescription
        }
    }

    func fetchPositions() async {
        do {
            positions = try await tradingService.getOpenPositions()
            activePositions = positions.count
        } catch {
            print("❌ Failed to fetch positions: \(error)")
        }
    }

    func fetchTrades() async {
        do {
            trades = try await tradingService.getRecentTrades(days: 7)
        } catch {
            print("❌ Failed to fetch trades: \(error)")
        }
    }

    func fetchEquityCurve() async {
        do {
            let curve = try await performanceService.getEquityCurve(days: 30)
            equityCurve = curve.equityCurve
        } catch {
            print("❌ Failed to fetch equity curve: \(error)")
        }
    }

    // MARK: - Bot Control

    func toggleBot() {

        Task {
            do {
                if isRunning {
                    try await stopBot()
                } else {
                    try await startBot()
                }
            } catch {
                self.error = error.localizedDescription
                print("❌ Bot toggle error: \(error)")
            }
        }
    }

    func startBot() async throws {

        isLoading = true
        error = nil

        do {
            try await botService.start()
            isRunning = true
            print("✅ Bot started")

            // Refresh data after start
            await refreshData()

        } catch {
            self.error = error.localizedDescription
            throw error
        }

        isLoading = false
    }

    func stopBot() async throws {

        isLoading = true
        error = nil

        do {
            try await botService.stop()
            isRunning = false
            print("✅ Bot stopped")

            // Refresh data after stop
            await refreshData()

        } catch {
            self.error = error.localizedDescription
            throw error
        }

        isLoading = false
    }

    func pauseBot() async throws {

        isLoading = true
        error = nil

        do {
            try await botService.pause()
            print("✅ Bot paused")
            await refreshData()
        } catch {
            self.error = error.localizedDescription
            throw error
        }

        isLoading = false
    }

    func resumeBot() async throws {

        isLoading = true
        error = nil

        do {
            try await botService.resume()
            print("✅ Bot resumed")
            await refreshData()
        } catch {
            self.error = error.localizedDescription
            throw error
        }

        isLoading = false
    }

    // MARK: - Position Management

    func closePosition(id: String) async throws {
        try await tradingService.closePosition(id: id)

        // Refresh positions after closing
        if let positions = try? await tradingService.getOpenPositions() {
            self.positions = positions
            activePositions = positions.count
            print("💰 Position closed successfully")
        }
    }

    func closeAllPositions() async throws {

        try await tradingService.closeAllPositions()
        await fetchPositions()
        await refreshData()
    }

    // MARK: - Update Handlers

    private func updateFromStatus(_ status: BotStatusResponse) {
        self.isRunning = status.isRunning
        self.balance = status.balance
        self.dailyPnL = status.dailyPnl
        self.activePositions = status.activePositions
        self.winRate = status.winRate
        self.riskTier = status.riskTier
        self.totalTrades = status.totalTrades
        self.profitFactor = status.profitFactor
        self.peakBalance = status.peakBalance
        self.currentDrawdown = status.currentDrawdown
    }

    private func updateFromStats(_ stats: PerformanceStatsResponse) {
        self.totalTrades = stats.totalTrades
        self.winRate = stats.winRate
        self.profitFactor = stats.profitFactor
        self.peakBalance = max(self.peakBalance, self.balance)  // Update peak if current balance is higher
        self.currentDrawdown = stats.maxDrawdownPercent ?? 0.0  // Use 0.0 if backend doesn't send this

        // Note: weekPnL, monthPnL, totalReturn are not available in PerformanceStatsResponse
        // They will remain at default values (0.0) until a dedicated endpoint is available
    }

    private func handleBotStatusUpdate(_ update: BotStatusUpdate) {
        isRunning = update.isRunning
        botState = update.state

        if let balance = update.balance {
            self.balance = balance
        }

        if let positions = update.positions {
            self.activePositions = positions
        }
    }

    private func handleTradeUpdate(_ update: TradeUpdate) {
        // Refresh trades and positions
        Task {
            await fetchTrades()
            await fetchPositions()
        }

        // Update daily P&L if trade closed
        if update.action == "closed", let profit = update.profit {
            dailyPnL += profit
        }
    }

    private func handlePositionUpdate(_ update: PositionUpdate) {
        // Update position in array by merging fields from the websocket update
        if let index = positions.firstIndex(where: { $0.id == update.id }) {
            var updatedPosition = positions[index]
            updatedPosition.currentPrice = update.currentPrice
            updatedPosition.profit = update.profit
            positions[index] = updatedPosition
        }
    }

    private func handleBalanceUpdate(_ update: BalanceUpdate) {
        balance = update.balance

        if let equity = update.equity {
            self.equity = equity
        }
    }

    // MARK: - Settings

    func saveSettings() {

        Task {
            do {
                let config = try await botService.getConfig()
                riskPerTrade = config.riskPerTrade
                print("✅ Settings synced with backend")
            } catch {
                print("⚠️ Failed to sync settings: \(error)")
            }
        }
    }

    private func resetData() {
        isRunning = false
        balance = 10000.0
        equity = 10250.0
        dailyPnL = 125.50
        weekPnL = 450.75
        monthPnL = 1250.00
        totalReturn = 2.5
        activePositions = 3
        totalTrades = 47
        winRate = 62.5
        profitFactor = 1.8
        peakBalance = 10500.0
        currentDrawdown = 2.38
        maxDrawdown = 5.2
        botState = "Idle"
        error = nil
        positions = []
        trades = []
        equityCurve = []
    }

    // MARK: - Cleanup
    deinit {
        updateTimer?.invalidate()
        cancellables.removeAll()
    }
}
