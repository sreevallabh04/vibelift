class AppConstants {
  // App Info
  static const String appName = 'VibeLift';
  static const String appVersion = '1.0.0';

  // Database
  static const String dbName = 'vibelift.db';

  // Notification IDs
  static const int mealReminderNotificationId = 1;
  static const int weightReminderNotificationId = 2;
  static const int workoutReminderNotificationId = 3;

  // Goals
  static const List<String> fitnessGoals = ['Bulk', 'Cut', 'Powerlifting'];

  // Workout Splits
  static const Map<String, List<String>> workoutSplits = {
    'Bulk': ['Push', 'Pull', 'Legs', 'Rest', 'Push', 'Pull', 'Legs'],
    'Cut': ['Upper', 'Lower', 'Rest', 'Upper', 'Lower', 'Cardio', 'Rest'],
    'Powerlifting': [
      'Squat Focus',
      'Bench Focus',
      'Deadlift Focus',
      'Rest',
      'Squat Focus',
      'Bench Focus',
      'Rest'
    ],
  };

  // Macro Goals (example defaults)
  static const double defaultProteinGoal = 150.0; // grams
  static const double defaultCarbsGoal = 250.0;
  static const double defaultFatsGoal = 70.0;
  static const double defaultFiberGoal = 30.0;
  static const double defaultCaloriesGoal = 2500.0;
}
