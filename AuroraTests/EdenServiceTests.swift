// EdenServiceTests.swift
import XCTest

@testable import Aurora

class EdenServiceTests: XCTestCase {

    // Mock HTTPClient or use a test configuration if possible
    // Since we can't easily mock the singleton HTTPClient.shared without refactoring,
    // we will write tests that verify the URL construction logic if possible,
    // or basic integration tests if running against a mock server.
    // Given the constraints, we'll add basic tests that ensure the services can be instantiated
    // and methods called without crashing (even if they fail network requests).

    @MainActor
    func testStrategyServiceInit() {
        let service = StrategyService.shared
        XCTAssertNotNil(service)
    }

    @MainActor
    func testTradeServiceInit() {
        let service = TradeService.shared
        XCTAssertNotNil(service)
    }

    @MainActor
    func testAccountServiceInit() {
        let service = AccountService.shared
        XCTAssertNotNil(service)
    }

    @MainActor
    func testPerformanceServiceInit() {
        let service = PerformanceService.shared
        XCTAssertNotNil(service)
    }

    @MainActor
    func testWebSocketManagerInit() {
        let manager = WebSocketManager.shared
        XCTAssertNotNil(manager)
        XCTAssertTrue(manager.notifications.isEmpty)
    }

    // Note: Comprehensive unit testing would require dependency injection for HTTPClient
    // to mock network responses. For now, these smoke tests ensure basic integrity.
}
