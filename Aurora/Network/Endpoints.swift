//
//  Endpoints.swift
//  Aurora
//
//  Eden Backend via Tailscale
//  Primary: https://desktop-p1p7892.taildbc5d3.ts.net:8443
//  Fallback IP: https://100.96.92.39:8443
//

import Foundation

struct APIEndpoints {
    /// Primary backend URL via Tailscale hostname
    static let baseURL = "https://desktop-p1p7892.taildbc5d3.ts.net:8443"

    /// Fallback IP if DNS is not working (uncomment to use)
    // static let baseURL = "https://100.96.92.39:8443"

    /// WebSocket base URL (wss if https)
    static let wsBaseURL = "wss://desktop-p1p7892.taildbc5d3.ts.net:8443"

    /// Fallback WebSocket IP (uncomment to use)
    // static let wsBaseURL = "wss://100.96.92.39:8443"

    // MARK: - Authentication
    struct Auth {
        static let register = "\(baseURL)/auth/register-local"
        static let login = "\(baseURL)/auth/login-local"
        static let logout = "\(baseURL)/auth/logout"
        static let refresh = "\(baseURL)/auth/refresh"
        static let me = "\(baseURL)/auth/me"
        static let verifyToken = "\(baseURL)/auth/verify"
    }

    // MARK: - Bot Control
    struct Bot {
        static let status = "\(baseURL)/bot/status"
        static let start = "\(baseURL)/bot/start"
        static let stop = "\(baseURL)/bot/stop"
        static let pause = "\(baseURL)/bot/pause"
        static let resume = "\(baseURL)/bot/resume"
        static let health = "\(baseURL)/bot/health"
        static let config = "\(baseURL)/bot/config"
        static let updateConfig = "\(baseURL)/bot/config"
    }

    // MARK: - Positions
    struct Positions {
        static let open = "\(baseURL)/trades/open"  // FIXED: Server uses /trades/open not /positions/open
        static let list = open  // Alias for compatibility
        static let closeAll = "\(baseURL)/positions/close-all"

        static func byId(_ id: String) -> String {
            return "\(baseURL)/positions/\(id)"
        }
        static func close(_ id: String) -> String {
            return "\(baseURL)/positions/\(id)/close"
        }
    }

    // MARK: - Trades
    struct Trades {
        static let recent = "\(baseURL)/trades/recent"
        static let open = "\(baseURL)/trades/open"
        static let history = "\(baseURL)/trades/history"
        static let closed = "\(baseURL)/trades/closed"
        static let logs = "\(baseURL)/trades/logs"

        static func byId(_ id: String) -> String {
            return "\(baseURL)/trades/\(id)"
        }
        static func recent(days: Int) -> String {
            return "\(recent)?days=\(days)"
        }
        static func history(limit: Int) -> String {
            return "\(history)?limit=\(limit)"
        }
        static func close(_ id: String) -> String {
            return "\(baseURL)/trades/\(id)/close"
        }
        static func modify(_ id: String) -> String {
            return "\(baseURL)/trades/\(id)/modify"
        }
    }

    // MARK: - Performance
    struct Performance {
        static let stats = "\(baseURL)/performance/stats"
        static let summary = stats  // Alias for compatibility
        static let daily = "\(baseURL)/performance/daily-summary"
        static let equity = "\(baseURL)/performance/equity-curve"  // FIXED: Was /equity
        static let metrics = "\(baseURL)/performance/metrics"

        static func equity(days: Int) -> String {
            return "\(equity)?days=\(days)"
        }
    }

    // MARK: - Account
    struct Account {
        static let info = "\(baseURL)/account/info"
        static let balance = "\(baseURL)/account/balance"
        static let history = "\(baseURL)/account/history"

        // MT5 Account Management
        static let mt5Accounts = "\(baseURL)/account/mt5"
        static let mt5List = mt5Accounts
        static let mt5Primary = "\(baseURL)/account/mt5/primary"
        static let mt5Create = mt5Accounts

        static func mt5Update(id: Int) -> String {
            return "\(baseURL)/account/mt5/\(id)"
        }

        static func mt5Delete(id: Int) -> String {
            return "\(baseURL)/account/mt5/\(id)"
        }
    }

    // MARK: - MT5Account (Compatibility struct)
    struct MT5Account {
        static let list = Account.mt5Accounts
        static let primary = Account.mt5Primary
        static let create = Account.mt5Create

        static func update(accountId: Int) -> String {
            return Account.mt5Update(id: accountId)
        }

        static func delete(accountId: Int) -> String {
            return Account.mt5Delete(id: accountId)
        }
    }

    // MARK: - Strategies
    struct Strategies {
        static let list = "\(baseURL)/strategies"
        static let upload = "\(baseURL)/strategies"
        static let validated = "\(baseURL)/strategies/validated"
        static let active = "\(baseURL)/strategies/active"
        static let discover = "\(baseURL)/strategies/discover"

        static func byId(_ id: String) -> String {
            return "\(baseURL)/strategies/\(id)"
        }

        static func toggle(_ id: String) -> String {
            return "\(baseURL)/strategies/\(id)/toggle"
        }

        static func activate(_ id: String) -> String {
            return "\(baseURL)/strategies/\(id)/activate"
        }

        static func deactivate(_ id: String) -> String {
            return "\(baseURL)/strategies/\(id)/deactivate"
        }

        static func promote(_ id: String) -> String {
            return "\(baseURL)/strategies/\(id)/promote"
        }

        static func policy(_ id: String) -> String {
            return "\(baseURL)/strategies/\(id)/policy"
        }

        static func backtest(_ id: String) -> String {
            return "\(baseURL)/strategies/\(id)/backtest"
        }
    }

    // MARK: - Strategy (Singular - for config)
    struct Strategy {
        static let config = "\(baseURL)/strategy/config"
        static let symbols = "\(baseURL)/strategy/symbols"
    }

    // MARK: - Device & Notifications
    struct Device {
        static let register = "\(baseURL)/device/register"
    }

    // MARK: - Test Orders
    struct TestOrders {
        static let place = "\(baseURL)/orders/test"
    }

    // MARK: - System
    struct System {
        static let health = "\(baseURL)/health"
        static let status = "\(baseURL)/system/status"
        static let info = "\(baseURL)/info"
    }

    // MARK: - WebSocket
    struct WebSocket {
        static let notifications = "\(wsBaseURL)/ws/notifications"  // FIXED: No /api prefix

        static func updates(token: String) -> String {
            return "\(wsBaseURL)/ws/updates/\(token)"
        }
    }
}
