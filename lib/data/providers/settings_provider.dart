import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibelift/data/providers/database_provider.dart';

// Theme mode provider
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref ref;

  ThemeModeNotifier(this.ref) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final database = ref.read(databaseProvider);
    final themeValue = await database.getSetting('theme_mode');
    if (themeValue != null) {
      state = ThemeMode.values.firstWhere(
        (mode) => mode.name == themeValue,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final database = ref.read(databaseProvider);
    await database.setSetting('theme_mode', mode.name);
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(newMode);
  }
}

// Fitness goal provider
final fitnessGoalProvider =
    StateNotifierProvider<FitnessGoalNotifier, String>((ref) {
  return FitnessGoalNotifier(ref);
});

class FitnessGoalNotifier extends StateNotifier<String> {
  final Ref ref;

  FitnessGoalNotifier(this.ref) : super('Bulk') {
    _loadGoal();
  }

  Future<void> _loadGoal() async {
    final database = ref.read(databaseProvider);
    final goal = await database.getSetting('fitness_goal');
    if (goal != null) {
      state = goal;
    }
  }

  Future<void> setGoal(String goal) async {
    state = goal;
    final database = ref.read(databaseProvider);
    await database.setSetting('fitness_goal', goal);
  }
}

// Goal weight provider
final goalWeightProvider =
    StateNotifierProvider<GoalWeightNotifier, double?>((ref) {
  return GoalWeightNotifier(ref);
});

class GoalWeightNotifier extends StateNotifier<double?> {
  final Ref ref;

  GoalWeightNotifier(this.ref) : super(null) {
    _loadGoalWeight();
  }

  Future<void> _loadGoalWeight() async {
    final database = ref.read(databaseProvider);
    final weightStr = await database.getSetting('goal_weight');
    if (weightStr != null) {
      state = double.tryParse(weightStr);
    }
  }

  Future<void> setGoalWeight(double weight) async {
    state = weight;
    final database = ref.read(databaseProvider);
    await database.setSetting('goal_weight', weight.toString());
  }
}
