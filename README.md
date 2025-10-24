# VibeLift 🏋️

A visually appealing, offline-first fitness tracking app built with Flutter.

## ✨ Features

### 🍽️ Food Tracker
- AI-powered meal analysis using Gemini API
- Automatic macro calculation (protein, carbs, fats, fiber, calories)
- Save favorite meals for quick logging
- Daily nutrition tracking with visual progress rings
- Swipe to delete meals

### ⚖️ Weight Tracker
- Log daily weight entries with notes
- Beautiful line chart showing weight trends
- Goal weight tracking with progress percentage
- Weight change indicators
- Historical data with swipe-to-delete

### 💪 Lifting Tracker
- Customizable workout splits based on fitness goals (Bulk/Cut/Powerlifting)
- Personal Record (PR) detection with confetti animation
- Exercise library with 20+ pre-loaded exercises
- Track sets, reps, and weight for each exercise
- Workout history with detailed session view

### 📊 Dashboard
- Overview of today's nutrition
- Quick stats: current weight and workout count
- Recent meals display
- Smooth navigation between all features

### ⚙️ Settings
- Dark/Light theme toggle
- Fitness goal selection
- Goal weight configuration
- App info and data management

## 🛠️ Tech Stack

- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **Local Database**: Drift (SQLite)
- **AI Integration**: Google Generative AI (Gemini)
- **Charts**: fl_chart
- **Animations**: Lottie
- **Notifications**: flutter_local_notifications

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- A device or emulator for testing

### Installation

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd vibelift
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate Drift database code**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. **Download Poppins font**
- Visit [Google Fonts - Poppins](https://fonts.google.com/specimen/Poppins)
- Download the font family
- Extract and place the following files in `assets/fonts/`:
  - `Poppins-Regular.ttf`
  - `Poppins-Medium.ttf`
  - `Poppins-SemiBold.ttf`
  - `Poppins-Bold.ttf`

5. **Run the app**
```bash
flutter run
```

## 🎨 Design Philosophy

VibeLift follows modern UI/UX principles:
- **Material Design 3** with custom color schemes
- **Rounded corners** and soft shadows for cards
- **Gradient accents** for primary actions
- **Smooth animations** for all interactions
- **Intuitive gestures** (swipe to delete, pull to refresh)
- **Responsive layouts** that adapt to different screen sizes

## 📱 Screenshots

(Add screenshots of your app here once you run it)

## 🔐 API Configuration

The app uses Google's Gemini API for meal analysis. The API key is configured in `lib/core/constants.dart`:

```dart
static const String geminiApiKey = 'YOUR_API_KEY_HERE';
```

**Note**: For production, consider using environment variables or secure storage for API keys.

## 📦 Project Structure

```
lib/
├── main.dart                          # App entry point
├── core/
│   ├── constants.dart                 # App constants and configurations
│   └── theme/
│       ├── app_colors.dart            # Color palette
│       └── app_theme.dart             # Theme configurations
├── data/
│   ├── db/
│   │   └── database.dart              # Drift database setup
│   ├── models/
│   │   └── meal_macros.dart           # Data models
│   ├── providers/
│   │   ├── database_provider.dart     # Database providers
│   │   ├── gemini_provider.dart       # AI service provider
│   │   └── settings_provider.dart     # Settings providers
│   └── services/
│       └── gemini_service.dart        # Gemini API integration
├── screens/
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── food_tracker/
│   │   └── food_tracker_screen.dart
│   ├── lifting_tracker/
│   │   └── lifting_tracker_screen.dart
│   ├── weight_tracker/
│   │   └── weight_tracker_screen.dart
│   └── settings/
│       └── settings_screen.dart
└── widgets/
    ├── animated_progress_ring.dart    # Custom progress indicator
    ├── custom_button.dart             # Reusable button widgets
    ├── lottie_loader.dart             # Animation helpers
    └── stat_card.dart                 # Dashboard stat cards
```

## 🔄 Future Enhancements

- [ ] Firebase cloud backup
- [ ] Export data as JSON/CSV
- [ ] Meal photos with image recognition
- [ ] Social features (share workouts, compete with friends)
- [ ] Advanced workout programming
- [ ] Nutrition insights and recommendations
- [ ] Wearable device integration
- [ ] Calorie burn estimation

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 💪 Acknowledgments

- **Google Generative AI** for meal analysis
- **Lottie** for beautiful animations
- **Flutter Community** for amazing packages

---

Built with ❤️ using Flutter

