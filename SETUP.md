# VibeLift Setup Guide 🚀

Follow these steps to get VibeLift up and running on your machine.

## Prerequisites

Before starting, ensure you have:

1. **Flutter SDK** (3.0.0+)
   ```bash
   flutter --version
   ```

2. **Dart SDK** (comes with Flutter)

3. **Android Studio** or **VS Code** with Flutter extension

4. **Git** (for cloning the repository)

## Step-by-Step Setup

### 1. Install Dependencies

Run the following command in the project directory:

```bash
flutter pub get
```

This will download all required packages including:
- Riverpod (state management)
- Drift (local database)
- fl_chart (charting)
- Lottie (animations)
- Google Generative AI (Gemini)
- And more...

### 2. Generate Database Code

Drift requires code generation for the database schema. Run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This command will:
- Generate `database.g.dart` file
- Create necessary database boilerplate code
- May take 30-60 seconds to complete

**Note**: You'll see `database.g.dart` created in `lib/data/db/`

### 3. (Optional) Add Custom Fonts

For the best visual experience, download and add the Poppins font:

1. Visit [Google Fonts - Poppins](https://fonts.google.com/specimen/Poppins)
2. Click "Download family"
3. Extract the ZIP file
4. Copy these files to `assets/fonts/`:
   - `Poppins-Regular.ttf`
   - `Poppins-Medium.ttf`
   - `Poppins-SemiBold.ttf`
   - `Poppins-Bold.ttf`

5. Then, in `pubspec.yaml`, uncomment the fonts section:
   ```yaml
   fonts:
     - family: Poppins
       fonts:
         - asset: assets/fonts/Poppins-Regular.ttf
         # ... etc
   ```

6. In `lib/core/theme/app_theme.dart`, uncomment all `fontFamily: 'Poppins'` lines

**If you skip this step**, the app will use system default fonts (still looks great!).

### 4. Verify Setup

Check if everything is configured correctly:

```bash
flutter doctor
```

Ensure all checkmarks are green, especially:
- ✓ Flutter (Channel stable)
- ✓ Android toolchain
- ✓ Connected device

### 5. Run the App

For Android:
```bash
flutter run
```

For specific device:
```bash
flutter devices  # List available devices
flutter run -d <device-id>
```

For web (beta):
```bash
flutter run -d chrome
```

## First Launch

When you first open VibeLift:

1. **Dashboard** will be empty (no data yet)
2. Navigate to **Settings** → Set your fitness goal (Bulk/Cut/Powerlifting)
3. Set your **goal weight** in Settings
4. Go to **Food** tab → Log your first meal!
5. Go to **Workouts** tab → Start your first workout!
6. Go to **Weight** tab → Log your current weight!

## Troubleshooting

### Issue: "database.g.dart not found"

**Solution**: Run the build_runner command again:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: "Lottie assets not found"

**Solution**: Make sure you ran `flutter pub get` and the `assets/lottie/` folder exists with JSON files.

### Issue: Font errors

**Solution**: 
1. Comment out the fonts section in `pubspec.yaml`
2. Comment out `fontFamily: 'Poppins'` in `lib/core/theme/app_theme.dart`
3. Run `flutter clean && flutter pub get`

### Issue: API errors when analyzing meals

**Solution**: The Gemini API key is included for testing. If it stops working:
1. Get your own free API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Replace the key in `lib/core/constants.dart`:
   ```dart
   static const String geminiApiKey = 'YOUR_NEW_KEY';
   ```

### Issue: Build errors on iOS

**Solution**: iOS requires additional setup:
```bash
cd ios
pod install
cd ..
flutter run
```

## Development Tips

### Hot Reload
Press `r` in the terminal to hot reload during development.

### Hot Restart
Press `R` (capital) to hot restart the entire app.

### Clean Build
If you encounter strange errors:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Debugging
Use VS Code or Android Studio debugger for breakpoints and inspection.

## Project Structure

```
vibelift/
├── lib/
│   ├── main.dart                 # Entry point
│   ├── core/                     # Constants, themes
│   ├── data/                     # Database, models, services
│   ├── screens/                  # UI screens
│   └── widgets/                  # Reusable widgets
├── assets/
│   ├── lottie/                   # Animation files
│   ├── fonts/                    # Font files (add manually)
│   └── images/                   # Images
└── pubspec.yaml                  # Dependencies
```

## Next Steps

After successful setup:

1. ✅ Explore all 5 screens (Dashboard, Food, Workouts, Weight, Settings)
2. ✅ Try logging a meal with AI analysis
3. ✅ Test PR detection in workouts (lift heavier than before!)
4. ✅ Toggle dark mode in Settings
5. ✅ Track your weight progress with the chart

## Need Help?

- Check the [README.md](README.md) for feature documentation
- Review code comments in the source files
- Flutter docs: https://docs.flutter.dev

---

Happy lifting! 💪

