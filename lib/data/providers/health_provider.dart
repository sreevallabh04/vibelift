import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibelift/data/services/health_service.dart';

final healthServiceProvider = Provider<HealthService>((ref) {
  return HealthService();
});

final healthAuthorizationProvider = FutureProvider<bool>((ref) async {
  final healthService = ref.watch(healthServiceProvider);
  return await healthService.requestAuthorization();
});

final todayStepsProvider = FutureProvider<int>((ref) async {
  final healthService = ref.watch(healthServiceProvider);
  return await healthService.getTodaySteps();
});

final todayCaloriesProvider = FutureProvider<double>((ref) async {
  final healthService = ref.watch(healthServiceProvider);
  return await healthService.getTodayCalories();
});

final latestHealthWeightProvider = FutureProvider<double?>((ref) async {
  final healthService = ref.watch(healthServiceProvider);
  return await healthService.getLatestWeight();
});

final todayWorkoutsProvider = FutureProvider<int>((ref) async {
  final healthService = ref.watch(healthServiceProvider);
  final workouts = await healthService.getTodayWorkouts();
  return workouts.length;
});

// Compute current streak (consecutive days ending today with steps >= threshold)
final currentStreakProvider = FutureProvider<int>((ref) async {
  const int minSteps = 1000;
  final healthService = ref.watch(healthServiceProvider);
  final now = DateTime.now();
  final start = now.subtract(const Duration(days: 30));
  final stepsMap = await healthService.getStepsInRange(start, now);

  int streak = 0;
  for (int i = 0; i < 30; i++) {
    final day =
        DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
    final steps = stepsMap[day] ?? 0;
    if (steps >= minSteps) {
      streak += 1;
    } else {
      if (i == 0) {
        // today doesn't meet threshold → no streak
        streak = 0;
      }
      break;
    }
  }
  return streak;
});
