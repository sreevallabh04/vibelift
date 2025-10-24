# API Configuration Setup

## Security Notice

API keys are now stored in a separate file that is **excluded from version control** for security.

## Setup Instructions

### Step 1: Create API Config File

Copy the template file:

```bash
cp lib/core/api_config.template.dart lib/core/api_config.dart
```

Or on Windows:
```powershell
copy lib\core\api_config.template.dart lib\core\api_config.dart
```

### Step 2: Add Your API Key

Open `lib/core/api_config.dart` and replace the placeholder:

```dart
class ApiConfig {
  static const String groqApiKey = 'YOUR_ACTUAL_GROQ_API_KEY_HERE';
}
```

### Step 3: Get Your API Key

1. Visit [Groq Console](https://console.groq.com/)
2. Sign up or log in
3. Navigate to API Keys section
4. Create a new API key
5. Copy it to `api_config.dart`

## Current API Key

The current API key is already configured in the created `api_config.dart` file.

## Important Notes

- `api_config.dart` is in `.gitignore` and will **NOT** be committed
- `api_config.template.dart` is the template for others to use
- Never commit actual API keys to version control
- Each developer needs to create their own `api_config.dart` file

## For Production

Consider using:
- Environment variables
- Backend proxy for API calls
- Firebase Remote Config
- Secrets management service

