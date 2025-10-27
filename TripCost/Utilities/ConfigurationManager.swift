import Foundation

/// Manages app configuration from environment and config files
class ConfigurationManager {
    static let shared = ConfigurationManager()
    
    private init() {}
    
    /// Get OpenWeatherMap API key from configuration
    /// Priority: 1. .env file, 2. Info.plist, 3. Environment variable
    var openWeatherAPIKey: String? {
        // Try .env file first
        if let envKey = readFromEnvFile() {
            return envKey
        }
        
        // Try Info.plist
        if let plistKey = Bundle.main.object(forInfoDictionaryKey: "OPENWEATHER_API_KEY") as? String,
           !plistKey.isEmpty && plistKey != "$(OPENWEATHER_API_KEY)" {
            return plistKey
        }
        
        // Try environment variable (for CI/CD)
        if let envVar = ProcessInfo.processInfo.environment["OPENWEATHER_API_KEY"],
           !envVar.isEmpty {
            return envVar
        }
        
        return nil
    }
    
    /// Read API key from .env file in project root
    private func readFromEnvFile() -> String? {
        // Get project root (go up from app bundle)
        guard let projectRoot = findProjectRoot() else {
            print("⚠️ Could not find project root")
            return nil
        }
        
        let envPath = projectRoot.appendingPathComponent(".env")
        
        guard FileManager.default.fileExists(atPath: envPath.path) else {
            print("ℹ️ No .env file found at: \(envPath.path)")
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
                        print("✅ Loaded API key from .env file")
                        return value
                    }
                }
            }
        } catch {
            print("⚠️ Error reading .env file: \(error)")
        }
        
        return nil
    }
    
    /// Find project root directory by walking up from bundle
    private func findProjectRoot() -> URL? {
        // In development, Bundle.main.bundleURL points to DerivedData
        // Walk up to find .git or TripCost.xcodeproj
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
