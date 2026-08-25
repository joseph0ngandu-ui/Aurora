//
//  StrategiesService.swift
// Aurora
//
//  Service for listing strategies and toggling activation
//

import Foundation

struct StrategyItem: Codable, Identifiable {
    let id: String
    let name: String?
    let type: String?
    let parameters: [String: StringOrNumber]?
    let validated: Bool?
    var is_active: Bool?
    let performance: [String: DoubleOrString]?

    enum CodingKeys: String, CodingKey {
        case id, name, type, parameters, performance
        case validated = "is_validated"
        case is_active  // Matches API snake_case
    }
}

// Helpers to decode heterogenous JSON values
enum StringOrNumber: Codable {
    case string(String)
    case number(Double)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let d = try? container.decode(Double.self) {
            self = .number(d)
        } else {
            self = .string(try container.decode(String.self))
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .number(let d): try container.encode(d)
        case .string(let s): try container.encode(s)
        }
    }
}

enum DoubleOrString: Codable {
    case double(Double)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let d = try? container.decode(Double.self) {
            self = .double(d)
        } else {
            self = .string(try container.decode(String.self))
        }
    }
}

class StrategiesService: NSObject {
    static let shared = StrategiesService()

    // List all strategies
    func list(completion: @escaping (Result<[StrategyItem], Error>) -> Void) {
        guard let url = URL(string: APIEndpoints.Strategies.list) else {
            completion(.failure(NSError(domain: "bad_url", code: -1)))
            return
        }

        NetworkManager.shared.dataTask(with: url) { data, _, error in
            if let error = error { return completion(.failure(error)) }
            guard let data = data else {
                return completion(.failure(NSError(domain: "no_data", code: -1)))
            }
            do {
                // Try decoding as array first (standard REST)
                let decoder = JSONDecoder()
                // API uses snake_case, but our struct has mixed keys.
                // Let's rely on CodingKeys in struct or explicit mapping.
                // Since StrategyItem has 'is_active', let's not use .convertFromSnakeCase globally yet
                // unless we update the struct.

                let items = try decoder.decode([StrategyItem].self, from: data)
                completion(.success(items))
            } catch {
                print("❌ [Strategies] Array decode failed: \(error)")
                // Fallback: Try dictionary (legacy)
                do {
                    let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
                    let itemsData = try JSONSerialization.data(
                        withJSONObject: dict.values.map { $0 })
                    let items = try JSONDecoder().decode([StrategyItem].self, from: itemsData)
                    completion(.success(items))
                } catch {
                    print("❌ [Strategies] Dictionary decode failed: \(error)")
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // Toggle strategy (enable/disable)
    // Note: Backend automatically disables other strategies when enabling one
    func toggle(id: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: APIEndpoints.Strategies.toggle(id)) else {
            print("❌ [Strategies] Invalid toggle URL for strategy: \(id)")
            return completion(false)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        print("🔄 [Strategies] Toggling strategy: \(id)")
        NetworkManager.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [Strategies] Toggle failed: \(error.localizedDescription)")
                completion(false)
            } else {
                print("✅ [Strategies] Toggle successful for: \(id)")
                completion(true)
            }
        }.resume()
    }
}
