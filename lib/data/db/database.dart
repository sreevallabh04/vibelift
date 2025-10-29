import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:vibelift/core/constants.dart';

part 'database.g.dart';

// Meals Table
class Meals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text()();
  RealColumn get protein => real()();
  RealColumn get carbs => real()();
  RealColumn get fats => real()();
  RealColumn get fiber => real()();
  RealColumn get calories => real()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
}

// Weight Entries Table
class WeightEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get weight => real()();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
}

// Exercises Table
class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get category => text()(); // Push, Pull, Legs, Upper, Lower, etc.
  TextColumn get muscleGroup => text()(); // Chest, Back, Legs, etc.
}

// Workout Sessions Table
class WorkoutSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // e.g., "Push Day", "Leg Day"
  DateTimeColumn get date => dateTime()();
  IntColumn get durationMinutes => integer().nullable()();
}

// Workout Sets Table
class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get exerciseId => integer().references(Exercises, #id)();
  IntColumn get setNumber => integer()();
  RealColumn get weight => real()();
  IntColumn get reps => integer()();
  BoolColumn get isPR => boolean().withDefault(const Constant(false))();
}

// User Settings Table
class UserSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get key => text().unique()();
  TextColumn get value => text()();
}

@DriftDatabase(tables: [
  Meals,
  WeightEntries,
  Exercises,
  WorkoutSessions,
  WorkoutSets,
  UserSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Meals CRUD
  Future<List<Meal>> getAllMeals() => select(meals).get();

  Future<List<Meal>> getMealsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return (select(meals)
          ..where((m) => m.createdAt.isBetweenValues(startOfDay, endOfDay))
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)]))
        .get();
  }

  Future<List<Meal>> getFavoriteMeals() {
    return (select(meals)..where((m) => m.isFavorite.equals(true))).get();
  }

  Future<int> insertMeal(MealsCompanion meal) => into(meals).insert(meal);

  Future<bool> updateMeal(Meal meal) => update(meals).replace(meal);

  Future<int> deleteMeal(int id) =>
      (delete(meals)..where((m) => m.id.equals(id))).go();

  Stream<List<Meal>> watchMealsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return (select(meals)
          ..where((m) => m.createdAt.isBetweenValues(startOfDay, endOfDay))
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)]))
        .watch();
  }

  // Weight Entries CRUD
  Future<List<WeightEntry>> getAllWeightEntries() =>
      (select(weightEntries)..orderBy([(w) => OrderingTerm.desc(w.date)]))
          .get();

  Future<WeightEntry?> getLatestWeight() async {
    final entries = await (select(weightEntries)
          ..orderBy([(w) => OrderingTerm.desc(w.date)])
          ..limit(1))
        .get();
    return entries.isEmpty ? null : entries.first;
  }

  Future<int> insertWeightEntry(WeightEntriesCompanion entry) =>
      into(weightEntries).insert(entry);

  Future<int> deleteWeightEntry(int id) =>
      (delete(weightEntries)..where((w) => w.id.equals(id))).go();

  Stream<List<WeightEntry>> watchAllWeightEntries() =>
      (select(weightEntries)..orderBy([(w) => OrderingTerm.desc(w.date)]))
          .watch();

  Stream<WeightEntry?> watchLatestWeight() {
    return (select(weightEntries)
          ..orderBy([(w) => OrderingTerm.desc(w.date)])
          ..limit(1))
        .watchSingleOrNull();
  }

  // Exercises CRUD
  Future<List<Exercise>> getAllExercises() => select(exercises).get();

  Future<List<Exercise>> getExercisesByCategory(String category) {
    return (select(exercises)..where((e) => e.category.equals(category))).get();
  }

  Future<int> insertExercise(ExercisesCompanion exercise) =>
      into(exercises).insert(exercise);

  // Workout Sessions CRUD
  Future<List<WorkoutSession>> getAllWorkoutSessions() =>
      (select(workoutSessions)..orderBy([(w) => OrderingTerm.desc(w.date)]))
          .get();

  Future<List<WorkoutSession>> getWorkoutSessionsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return (select(workoutSessions)
          ..where((w) => w.date.isBetweenValues(startOfDay, endOfDay)))
        .get();
  }

  Future<int> insertWorkoutSession(WorkoutSessionsCompanion session) =>
      into(workoutSessions).insert(session);

  Future<int> deleteWorkoutSession(int id) =>
      (delete(workoutSessions)..where((w) => w.id.equals(id))).go();

  Stream<List<WorkoutSession>> watchWorkoutSessionsForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return (select(workoutSessions)
          ..where((w) => w.date.isBetweenValues(startOfDay, endOfDay)))
        .watch();
  }

  // Workout Sets CRUD
  Future<List<WorkoutSet>> getSetsForSession(int sessionId) {
    return (select(workoutSets)
          ..where((s) => s.sessionId.equals(sessionId))
          ..orderBy([(s) => OrderingTerm.asc(s.setNumber)]))
        .get();
  }

  Future<WorkoutSet?> getPersonalRecord(int exerciseId) async {
    final sets = await (select(workoutSets)
          ..where((s) => s.exerciseId.equals(exerciseId))
          ..orderBy([(s) => OrderingTerm.desc(s.weight)]))
        .get();
    return sets.isEmpty ? null : sets.first;
  }

  Future<int> insertWorkoutSet(WorkoutSetsCompanion set) =>
      into(workoutSets).insert(set);

  Future<bool> updateWorkoutSet(WorkoutSet set) =>
      update(workoutSets).replace(set);

  // User Settings CRUD
  Future<String?> getSetting(String key) async {
    final result = await (select(userSettings)..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return result?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(userSettings).insertOnConflictUpdate(
      UserSettingsCompanion.insert(key: key, value: value),
    );
  }

  // Helper method to seed default exercises
  Future<void> seedDefaultExercises() async {
    final existingExercises = await getAllExercises();
    if (existingExercises.isNotEmpty) return;

    final defaultExercises = [
      // Push Exercises
      ('Bench Press', 'Push', 'Chest'),
      ('Incline Dumbbell Press', 'Push', 'Chest'),
      ('Overhead Press', 'Push', 'Shoulders'),
      ('Lateral Raises', 'Push', 'Shoulders'),
      ('Tricep Pushdowns', 'Push', 'Triceps'),
      ('Chest Flyes', 'Push', 'Chest'),

      // Pull Exercises
      ('Deadlift', 'Pull', 'Back'),
      ('Pull-ups', 'Pull', 'Back'),
      ('Barbell Rows', 'Pull', 'Back'),
      ('Lat Pulldowns', 'Pull', 'Back'),
      ('Face Pulls', 'Pull', 'Rear Delts'),
      ('Bicep Curls', 'Pull', 'Biceps'),
      ('Hammer Curls', 'Pull', 'Biceps'),

      // Leg Exercises
      ('Squat', 'Legs', 'Quads'),
      ('Romanian Deadlift', 'Legs', 'Hamstrings'),
      ('Leg Press', 'Legs', 'Quads'),
      ('Leg Curls', 'Legs', 'Hamstrings'),
      ('Leg Extensions', 'Legs', 'Quads'),
      ('Calf Raises', 'Legs', 'Calves'),
      ('Lunges', 'Legs', 'Quads'),
    ];

    for (final (name, category, muscleGroup) in defaultExercises) {
      await insertExercise(
        ExercisesCompanion.insert(
          name: name,
          category: category,
          muscleGroup: muscleGroup,
        ),
      );
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.dbName));
    return NativeDatabase(file);
  });
}
