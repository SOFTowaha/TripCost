import Foundation

/// Weather information for a destination
struct WeatherData: Codable, Hashable {
    let temperature: Double // in Celsius
    let condition: String // e.g. "Clear", "Rain", "Clouds"
    let description: String // e.g. "clear sky", "light rain"
    let iconCode: String // weather icon code for SF Symbols mapping
    let humidity: Int? // percentage
    let windSpeed: Double? // m/s
    let fetchedAt: Date
    
    init(temperature: Double,
         condition: String,
         description: String,
         iconCode: String,
         humidity: Int? = nil,
         windSpeed: Double? = nil,
         fetchedAt: Date = Date()) {
        self.temperature = temperature
        self.condition = condition
        self.description = description
        self.iconCode = iconCode
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.fetchedAt = fetchedAt
    }
    
    /// Map OpenWeather icon codes to SF Symbol names
    var sfSymbol: String {
        switch iconCode {
        case "01d": return "sun.max.fill"
        case "01n": return "moon.stars.fill"
        case "02d": return "cloud.sun.fill"
        case "02n": return "cloud.moon.fill"
        case "03d", "03n": return "cloud.fill"
        case "04d", "04n": return "smoke.fill"
        case "09d", "09n": return "cloud.drizzle.fill"
        case "10d": return "cloud.sun.rain.fill"
        case "10n": return "cloud.moon.rain.fill"
        case "11d", "11n": return "cloud.bolt.fill"
        case "13d", "13n": return "snow"
        case "50d", "50n": return "cloud.fog.fill"
        default: return "cloud.fill"
        }
    }
    
    var temperatureInFahrenheit: Double {
        return (temperature * 9/5) + 32
    }
}
