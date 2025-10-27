# Configuration Guide

## Environment Variables

TripCost uses environment variables for sensitive configuration like API keys.

### Setup

1. **Copy the example file:**
   ```bash
   cp .env.example .env
   ```

2. **Add your API keys:**
   
   Edit `.env` and add your actual keys:
   ```bash
   # OpenWeatherMap API (free tier: https://openweathermap.org/api)
   OPENWEATHER_API_KEY=your_actual_api_key_here
   ```

3. **The .env file is git-ignored**
   
   Your `.env` file is automatically ignored by git, so your secrets stay private.

### Supported Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `OPENWEATHER_API_KEY` | Yes | OpenWeatherMap API key for weather data |

### How It Works

The app uses `ConfigurationManager` to load configuration in this order:

1. **`.env` file** (highest priority) - Local development
2. **Info.plist** - Build-time configuration
3. **Environment variables** - Runtime/CI/CD

### Security Best Practices

✅ **Do:**
- Use `.env` for local development
- Add `.env` to `.gitignore`
- Use `.env.example` as a template (no secrets)
- Use environment variables in CI/CD

❌ **Don't:**
- Commit `.env` files to version control
- Hardcode API keys in source code
- Share API keys in public repositories

### For Contributors

If you're contributing to TripCost:

1. Copy `.env.example` to `.env`
2. Get your own free OpenWeatherMap API key
3. Never commit your `.env` file

### Troubleshooting

**"API key not configured" warning?**
- Check that `.env` exists in project root
- Verify the format: `OPENWEATHER_API_KEY=your_key` (no spaces around =)
- Make sure the key is not `your_api_key_here`

**Still not working?**
- Check Xcode console for configuration logs (⚠️ and ✅ prefixes)
- Verify your API key is active on OpenWeatherMap
- Try cleaning build folder (Cmd+Shift+K) and rebuilding
