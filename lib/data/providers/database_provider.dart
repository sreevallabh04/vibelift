import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibelift/data/db/database.dart';

// Database instance provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => database.close());
  return database;
});

// Meals provider
final mealsProvider = StreamProvider.autoDispose<List<Meal>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.select(database.meals).watch();
});

final todayMealsProvider = StreamProvider.autoDispose<List<Meal>>((ref) {
  final database = ref.watch(databaseProvider);
  final today = DateTime.now();
  return database.getMealsForDate(today).asStream();
});

final favoriteMealsProvider = StreamProvider.autoDispose<List<Meal>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.getFavoriteMeals().asStream();
});

// Weight entries provider
final weightEntriesProvider =
    StreamProvider.autoDispose<List<WeightEntry>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.getAllWeightEntries().asStream();
});

final latestWeightProvider = StreamProvider.autoDispose<WeightEntry?>((ref) {
  final database = ref.watch(databaseProvider);
  return database.getLatestWeight().asStream();
});

// Exercises provider
final exercisesProvider = StreamProvider.autoDispose<List<Exercise>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.getAllExercises().asStream();
});

// Workout sessions provider
final workoutSessionsProvider =
    StreamProvider.autoDispose<List<WorkoutSession>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.getAllWorkoutSessions().asStream();
});

final todayWorkoutSessionsProvider =
    StreamProvider.autoDispose<List<WorkoutSession>>((ref) {
  final database = ref.watch(databaseProvider);
  final today = DateTime.now();
  return database.getWorkoutSessionsForDate(today).asStream();
});
