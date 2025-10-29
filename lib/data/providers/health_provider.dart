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

