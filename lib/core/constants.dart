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
    'PPL': [
      'Chest & Shoulders (Push A)',
      'Back (Pull A)',
      'Arms',
      'Chest & Shoulders (Push B)',
      'Back (Pull B)',
      'Legs',
      'Rest'
    ],
  };

  // Workout Exercises for PPL Split
  static const Map<String, List<String>> pplExercises = {
    'Chest & Shoulders (Push A)': [
      'Barbell Bench Press',
      'Incline Dumbbell Press',
      'Seated Shoulder Press',
      'Dumbbell Lateral Raises',
      'Cable Crossover / Pec Deck',
      'Face Pulls',
    ],
    'Back (Pull A)': [
      'Deadlifts',
      'Pull-Ups',
      'Barbell Rows',
      'Seated Cable Rows',
      'Lat Pulldown',
      'Hyperextensions / Back Extensions',
    ],
    'Arms': [
      'Barbell Curl',
      'Incline Dumbbell Curl',
      'Hammer Curl',
      'Skull Crushers',
      'Cable Rope Pushdown',
      'Overhead Dumbbell Extension',
      'Wrist Curls / Reverse Curls',
    ],
    'Chest & Shoulders (Push B)': [
      'Incline Barbell Press',
      'Dumbbell Fly / Cable Fly',
      'Arnold Press',
      'Upright Rows',
      'Front Raises',
      'Push-Ups',
    ],
    'Back (Pull B)': [
      'Pull-Ups (Wide Grip)',
      'T-Bar Rows',
      'Dumbbell Rows',
      'Straight-Arm Pulldown',
      'Cable Rear Delt Fly',
      'Shrugs',
    ],
    'Legs': [
      'Squats',
      'Romanian Deadlifts',
      'Leg Press',
      'Leg Curl',
      'Calf Raises (Standing + Seated)',
      'Walking Lunges',
    ],
  };

  // Macro Goals (example defaults)
  static const double defaultProteinGoal = 150.0; // grams
  static const double defaultCarbsGoal = 250.0;
  static const double defaultFatsGoal = 70.0;
  static const double defaultFiberGoal = 30.0;
  static const double defaultCaloriesGoal = 2500.0;
}
