class MealMacros {
  final double protein;
  final double carbs;
  final double fats;
  final double fiber;
  final double calories;

  MealMacros({
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.fiber,
    required this.calories,
  });

  factory MealMacros.fromJson(Map<String, dynamic> json) {
    return MealMacros(
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fats: (json['fats'] ?? 0).toDouble(),
      fiber: (json['fiber'] ?? 0).toDouble(),
      calories: (json['calories'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fiber': fiber,
      'calories': calories,
    };
  }

  MealMacros copyWith({
    double? protein,
    double? carbs,
    double? fats,
    double? fiber,
    double? calories,
  }) {
    return MealMacros(
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      fiber: fiber ?? this.fiber,
      calories: calories ?? this.calories,
    );
  }

  MealMacros operator +(MealMacros other) {
    return MealMacros(
      protein: protein + other.protein,
      carbs: carbs + other.carbs,
      fats: fats + other.fats,
      fiber: fiber + other.fiber,
      calories: calories + other.calories,
    );
  }

  static MealMacros zero() {
    return MealMacros(
      protein: 0,
      carbs: 0,
      fats: 0,
      fiber: 0,
      calories: 0,
    );
  }
}
