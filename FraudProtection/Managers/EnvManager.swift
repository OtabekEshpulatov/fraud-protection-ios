import Foundation

class EnvManager {
    static let shared = EnvManager()
    private var env: [String: String] = [:]

    private init() {
        loadEnv()
    }

    private func loadEnv() {
        guard let url = Bundle.main.url(forResource: ".env", withExtension: nil) else {
            print("⚠️ .env file not found in bundle.")
            return
        }

        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)

            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty, !trimmed.starts(with: "#") else { continue }

                let parts = trimmed.components(separatedBy: "=")
                if parts.count == 2 {
                    let key = parts[0].trimmingCharacters(in: .whitespaces)
                    let value = parts[1].trimmingCharacters(in: .whitespaces)
                    env[key] = value
                }
            }
        } catch {
            print("❌ Failed to load .env: \(error)")
        }
    }

    func get(_ key: String) -> String? {
        return env[key]
    }

    func require(_ key: String) -> String {
        guard let value = env[key] else {
            fatalError("Missing required env variable: \(key)")
        }
        return value
    }
}
