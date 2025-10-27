# Weather Feature Setup

The TripCost app now includes automatic weather fetching for trip destinations.

## Requirements

The weather feature uses the **OpenWeatherMap API** (free tier). You need to:

1. Sign up for a free API key at: https://openweathermap.org/api
2. Copy your API key
3. Add it to the WeatherService

## Configuration

Open `TripCost/Services/WeatherService.swift` and replace the placeholder:

```swift
private let apiKey = "YOUR_API_KEY_HERE" // TODO: Add your API key
```

With your actual API key:

```swift
private let apiKey = "your_actual_api_key_from_openweathermap"
```

## Features

- **Automatic Weather Fetch**: When you calculate a route, weather is automatically fetched for the destination
- **Route Preview**: Weather displays in a beautiful card on the route preview page
- **Saved with Trips**: Weather data is saved with your trips for future reference
- **Sharing**: Weather info is included when you share a trip
- **Graceful Handling**: If weather fetch fails (no API key, network issue), the app continues to work normally

## Weather Data Includes

- Temperature (°F and °C)
- Weather condition (Clear, Rain, Clouds, etc.)
- Condition description
- Weather icon (SF Symbols)
- Humidity percentage
- Wind speed

## Free Tier Limits

OpenWeatherMap free tier provides:
- 1,000 API calls per day
- Current weather data
- No credit card required

This is more than enough for typical personal use!

## Troubleshooting

**Weather not showing?**
1. Check that you added your API key to `WeatherService.swift`
2. Make sure you have internet connectivity
3. Verify your API key is active (can take a few minutes after signup)

**Want to use a different weather service?**
- You can replace `WeatherService` implementation with Apple WeatherKit, Weather Underground, or another provider
- Keep the same `WeatherData` model interface
- Update the mapping logic in `WeatherService.fetchWeather()`
