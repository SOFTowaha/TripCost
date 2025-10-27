import Foundation

/// Manages app configuration from environment and config files
class ConfigurationManager {
    static let shared = ConfigurationManager()
    
    private init() {}
    
    /// Get OpenWeatherMap API key from configuration
    /// Priority: 1) Keychain, 2) Environment variable, 3) Info.plist, 4) .env (Debug-only)
    var openWeatherAPIKey: String? {
        // 1) Keychain (best for end-user runtime config)
        if let stored = KeychainService.shared.get("OPENWEATHER_API_KEY"),
           !stored.isEmpty, stored != "your_api_key_here" {
            return stored
        }
        // 1) Environment variable (works well via Xcode scheme or CI)
        if let envVar = ProcessInfo.processInfo.environment["OPENWEATHER_API_KEY"],
           !envVar.isEmpty,
           envVar != "your_api_key_here" {
            return envVar
        }

        // 3) Info.plist (set via build settings or xcconfig)
        if let plistKey = Bundle.main.object(forInfoDictionaryKey: "OPENWEATHER_API_KEY") as? String,
           !plistKey.isEmpty && plistKey != "$(OPENWEATHER_API_KEY)" && plistKey != "your_api_key_here" {
            return plistKey
        }

        // 4) .env file (Debug builds only; helpful for local dev)
        #if DEBUG
        if let envKey = readFromEnvFile() {
            return envKey
        }
        #endif

        return nil
    }
    
    /// Read API key from .env file in project root
    private func readFromEnvFile() -> String? {
        // Get project root (go up from app bundle)
        guard let projectRoot = findProjectRoot() else { return nil }
        
        let envPath = projectRoot.appendingPathComponent(".env")
        
        guard FileManager.default.fileExists(atPath: envPath.path) else {
            // No .env in this environment (that's okay)
            return nil
        }
        
        do {
            let contents = try String(contentsOf: envPath, encoding: .utf8)
            
            // Parse .env file (simple key=value format)
            for line in contents.components(separatedBy: .newlines) {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                
                // Skip comments and empty lines
                if trimmed.isEmpty || trimmed.hasPrefix("#") {
                    continue
                }
                
                // Parse KEY=value
                let parts = trimmed.components(separatedBy: "=")
                if parts.count >= 2,
                   parts[0].trimmingCharacters(in: .whitespaces) == "OPENWEATHER_API_KEY" {
                    let value = parts.dropFirst().joined(separator: "=").trimmingCharacters(in: .whitespaces)
                    if !value.isEmpty && value != "your_api_key_here" {
                        #if DEBUG
                        print("✅ Loaded API key from .env file")
                        #endif
                        return value
                    }
                }
            }
        } catch {
            #if DEBUG
            print("⚠️ Error reading .env file: \(error)")
            #endif
        }
        
        return nil
    }
    
    /// Find project root directory by walking up from bundle
    private func findProjectRoot() -> URL? {
        // In development, Bundle.main.bundleURL points to DerivedData.
        // Walk up a few levels to find project markers (Debug only use-case).
        var current = Bundle.main.bundleURL
        
        // Try up to 10 levels
        for _ in 0..<10 {
            let gitPath = current.appendingPathComponent(".git")
            let xcprojPath = current.appendingPathComponent("TripCost.xcodeproj")
            
            if FileManager.default.fileExists(atPath: gitPath.path) ||
               FileManager.default.fileExists(atPath: xcprojPath.path) {
                return current
            }
            
            let parent = current.deletingLastPathComponent()
            if parent == current {
                break // Reached root
            }
            current = parent
        }
        
        return nil
    }
}
