import Foundation
import CoreLocation

/// Service to fetch weather data from OpenWeatherMap API
/// Free tier provides current weather and basic forecast
/// API key is loaded from .env file (see .env.example)
class WeatherService {
    static let shared = WeatherService()
    
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    /// API key loaded from configuration (see ConfigurationManager)
    private var apiKey: String? {
        ConfigurationManager.shared.openWeatherAPIKey
    }
    
    private init() {
        // Validate API key is configured
        if apiKey == nil {
            print("⚠️ WARNING: OpenWeatherMap API key not configured!")
            print("ℹ️ Create a .env file with OPENWEATHER_API_KEY=your_key")
            print("ℹ️ See .env.example for template")
        }
    }
    
    /// Fetch current weather for given coordinates
    func fetchWeather(for coordinate: CLLocationCoordinate2D) async throws -> WeatherData {
        // Check API key is configured
        guard let apiKey = apiKey, !apiKey.isEmpty else {
            throw WeatherError.missingAPIKey
        }
        
        // Build URL
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "lat", value: "\(coordinate.latitude)"),
            URLQueryItem(name: "lon", value: "\(coordinate.longitude)"),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric") // Celsius
        ]
        
        guard let url = components.url else {
            throw WeatherError.invalidURL
        }
        
        // Fetch data
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw WeatherError.requestFailed
        }
        
        // Parse JSON
        let decoder = JSONDecoder()
        let weatherResponse = try decoder.decode(OpenWeatherResponse.self, from: data)
        
        // Map to our model
        guard let main = weatherResponse.main,
              let weather = weatherResponse.weather.first else {
            throw WeatherError.invalidResponse
        }
        
        return WeatherData(
            temperature: main.temp,
            condition: weather.main,
            description: weather.description,
            iconCode: weather.icon,
            humidity: main.humidity,
            windSpeed: weatherResponse.wind?.speed
        )
    }
}

// MARK: - Error
enum WeatherError: LocalizedError {
    case invalidURL
    case requestFailed
    case invalidResponse
    case missingAPIKey
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid weather API URL"
        case .requestFailed: return "Weather request failed"
        case .invalidResponse: return "Invalid weather response"
        case .missingAPIKey: return "Weather API key not configured"
        }
    }
}

// MARK: - OpenWeatherMap API Response Models
private struct OpenWeatherResponse: Codable {
    let main: MainData?
    let weather: [WeatherInfo]
    let wind: WindData?
}

private struct MainData: Codable {
    let temp: Double
    let humidity: Int?
}

private struct WeatherInfo: Codable {
    let main: String // e.g. "Clear", "Rain"
    let description: String // e.g. "clear sky"
    let icon: String // e.g. "01d"
}

private struct WindData: Codable {
    let speed: Double
}
