# VibeLift Quick Start Guide ⚡

Get VibeLift running in 5 minutes!

## Prerequisites Check

```bash
flutter doctor
```

Make sure you have:
- ✅ Flutter SDK (3.0.0+)
- ✅ Android Studio or VS Code
- ✅ At least one target platform ready (Android/iOS/Web/Desktop)

## One-Time Setup

### Step 1: Install Dependencies

```bash
flutter pub get
```

**Expected output**: "Got dependencies!" ✅

### Step 2: Generate Database Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Expected output**: "Built with build_runner/aot" ✅  
**Result**: Creates `lib/data/db/database.g.dart`

### Step 3: Create Platform Files (If Needed)

#### For Android
```bash
flutter create --platforms android .
```

#### For iOS
```bash
flutter create --platforms ios .
```

#### For Web
```bash
flutter create --platforms web .
```

#### For Windows
```bash
flutter create --platforms windows .
```

#### For macOS
```bash
flutter create --platforms macos .
```

#### For Linux
```bash
flutter create --platforms linux .
```

#### For All Platforms (Recommended)
```bash
flutter create --platforms android,ios,web,windows,macos,linux .
```

**Note**: This adds platform-specific folders (android/, ios/, web/, etc.) without overwriting your lib/ code.

## Running the App

### Quick Run (Default Device)
```bash
flutter run
```

### Run on Specific Device

**Check available devices:**
```bash
flutter devices
```

**Run on specific device:**
```bash
flutter run -d <device-id>
```

**Examples:**
```bash
flutter run -d chrome        # Web in Chrome
flutter run -d windows       # Windows desktop
flutter run -d edge          # Web in Edge
flutter run -d emulator-5554 # Android emulator
```

### Development Mode (Hot Reload)
```bash
flutter run
# Then press 'r' for hot reload, 'R' for hot restart
```

### Release Build
```bash
# Android APK
flutter build apk --release

# iOS IPA (requires Mac)
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release
```

## First Launch Checklist

When the app opens:

1. ✅ You see the Dashboard screen
2. ✅ Bottom navigation shows 5 icons
3. ✅ App loads without errors
4. ✅ You can navigate between screens

## Initial Configuration

### In the Settings Tab:

1. **Set Fitness Goal**:
   - Tap "Fitness Goal"
   - Choose: Bulk / Cut / Powerlifting
   - This sets your workout split

2. **Set Goal Weight** (Optional):
   - Tap "Goal Weight"
   - Enter target weight in kg
   - Enables progress tracking

3. **Toggle Dark Mode**:
   - Switch on/off
   - Theme changes instantly

## Test Drive

### Test Food Tracking:
1. Go to **Food** tab
2. Type: "2 eggs, toast, coffee"
3. Tap **Analyze Meal**
4. Wait 2-5 seconds
5. Review macros
6. Tap **Save**
7. ✅ See success animation

### Test Weight Logging:
1. Go to **Weight** tab
2. Tap **+ button**
3. Enter your current weight
4. Tap **Save**
5. ✅ See weight card appear

### Test Workout:
1. Go to **Workouts** tab
2. Tap **+ button**
3. Keep suggested workout name
4. Tap **Start**
5. Tap **+ Add Exercise**
6. Select "Bench Press"
7. Enter: 60kg, 10 reps
8. Tap **Add**
9. ✅ See exercise logged

## Troubleshooting

### Issue: "database.g.dart not found"
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: API error when analyzing meals
The Gemini API key is included. If it fails:
- Check internet connection
- Wait a moment and retry
- The app will use default values if API fails

### Issue: No platform files
```bash
flutter create --platforms <platform-name> .
```

### Issue: Build errors
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### Issue: Hot reload not working
Press **R** (capital) for full restart instead of **r**.

## Useful Commands

### Development
```bash
flutter run                    # Run app
flutter clean                  # Clean build cache
flutter pub get               # Install dependencies
flutter doctor                # Check setup
flutter analyze               # Check code quality
```

### Building
```bash
flutter build apk             # Android release
flutter build web             # Web release
flutter build windows         # Windows release
```

### Debugging
```bash
flutter run -v                # Verbose output
flutter logs                  # View logs
flutter devices               # List devices
flutter emulators             # List emulators
```

## Performance Tips

### For Best Performance:
1. **Use Release mode** for actual usage: `flutter run --release`
2. **Profile mode** for debugging performance: `flutter run --profile`
3. **Debug mode** for development: `flutter run` (default)

### Difference:
- **Debug**: Slow, but has hot reload
- **Profile**: Fast, with performance tools
- **Release**: Fastest, optimized for users

## Advanced: Custom Fonts (Optional)

To use the Poppins font:

1. Download from [Google Fonts](https://fonts.google.com/specimen/Poppins)
2. Place these in `assets/fonts/`:
   - Poppins-Regular.ttf
   - Poppins-Medium.ttf
   - Poppins-SemiBold.ttf
   - Poppins-Bold.ttf

3. In `pubspec.yaml`, uncomment:
```yaml
fonts:
  - family: Poppins
    fonts:
      - asset: assets/fonts/Poppins-Regular.ttf
      # ... etc
```

4. In `lib/core/theme/app_theme.dart`, uncomment all:
```dart
fontFamily: 'Poppins',
```

5. Run:
```bash
flutter pub get
flutter run
```

## Project Structure

```
vibelift/
├── lib/               # Your app code (DON'T TOUCH!)
├── assets/            # Images, animations, fonts
├── android/           # Android platform (generated)
├── ios/              # iOS platform (generated)
├── web/              # Web platform (generated)
├── windows/          # Windows platform (generated)
├── pubspec.yaml      # Dependencies
└── README.md         # Documentation
```

## What's Next?

1. ✅ **Explore**: Try all 5 screens
2. ✅ **Log Data**: Add meals, weights, workouts
3. ✅ **Customize**: Change theme, set goals
4. ✅ **Check Dashboard**: See your progress
5. ✅ **Read**: Check USER_GUIDE.md for details

## Need Help?

- **Setup Issues**: See SETUP.md
- **Feature Questions**: See USER_GUIDE.md
- **Technical Details**: See PROJECT_SUMMARY.md
- **General Info**: See README.md

## Success Indicators

You'll know it's working when:
- ✅ App opens without errors
- ✅ You can navigate between all 5 screens
- ✅ Food analysis returns macro data
- ✅ Weight/workout data saves and displays
- ✅ Dark mode toggle works
- ✅ Animations play smoothly

## Ready to Ship?

Before deploying to stores:

1. **Update app info** in pubspec.yaml:
   - Name
   - Version
   - Description

2. **Add app icons**:
   ```bash
   flutter pub add flutter_launcher_icons
   # Configure and run icon generator
   ```

3. **Generate release builds**:
   ```bash
   flutter build apk --release
   flutter build ios --release
   flutter build web --release
   ```

4. **Test thoroughly** on multiple devices

5. **Submit to stores**:
   - Google Play Store
   - Apple App Store
   - Web hosting

---

**That's it! You're ready to lift! 💪**

Start by adding your first meal, logging your weight, and crushing a workout!

