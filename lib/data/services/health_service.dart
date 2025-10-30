import 'package:health/health.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

class HealthService {
  final Health _health = Health();

  // Define the types to get from health
  static final List<HealthDataType> types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.WORKOUT,
  ];

  static const MethodChannel _platform = MethodChannel('vibelift/health');

  /// Checks if Samsung Health is installed, enabled, and its version.
  Future<Map<String, dynamic>> getSamsungHealthStatus() async {
    try {
      final result = await _platform.invokeMethod('getSamsungHealthStatus');
      return Map<String, dynamic>.from(result);
    } catch (e) {
      return {
        'installed': false,
        'enabled': false,
        'version': 0,
        'error': e.toString(),
      };
    }
  }

  // Request authorization for health data access
  Future<bool> requestAuthorization() async {
    bool requested = false;

    try {
      // Request permissions
      requested = await _health.requestAuthorization(
        types,
        permissions: [
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ_WRITE,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
        ],
      );
    } catch (error) {
      developer.log('Exception in requestAuthorization: $error');
    }

    return requested;
  }

  // Check if health data access is authorized
  Future<bool> hasPermissions() async {
    bool? hasPermissions;
    try {
      hasPermissions = await _health.hasPermissions(
        types,
        permissions: [
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ_WRITE,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
          HealthDataAccess.READ,
        ],
      );
    } catch (error) {
      developer.log('Exception in hasPermissions: $error');
    }
    return hasPermissions ?? false;
  }

  // Get steps for today
  Future<int> getTodaySteps() async {
    int steps = 0;

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    try {
      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: midnight,
        endTime: now,
      );

      steps = healthData
          .where((data) => data.type == HealthDataType.STEPS)
          .fold(0, (sum, data) => sum + (data.value as num).toInt());
    } catch (error) {
      developer.log('Exception in getTodaySteps: $error');
    }

    return steps;
  }

  // Get steps for a specific date range
  Future<Map<DateTime, int>> getStepsInRange(DateTime start, DateTime end) async {
    Map<DateTime, int> stepsMap = {};

    try {
      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: start,
        endTime: end,
      );

      for (var data in healthData) {
        if (data.type == HealthDataType.STEPS) {
          final date = DateTime(
            data.dateFrom.year,
            data.dateFrom.month,
            data.dateFrom.day,
          );
          stepsMap[date] = (stepsMap[date] ?? 0) + (data.value as num).toInt();
        }
      }
    } catch (error) {
      developer.log('Exception in getStepsInRange: $error');
    }

    return stepsMap;
  }

  // Get calories burned for today
  Future<double> getTodayCalories() async {
    double calories = 0;

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    try {
      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: midnight,
        endTime: now,
      );

      calories = healthData
          .where((data) => data.type == HealthDataType.ACTIVE_ENERGY_BURNED)
          .fold(0.0, (sum, data) => sum + (data.value as num).toDouble());
    } catch (error) {
      developer.log('Exception in getTodayCalories: $error');
    }

    return calories;
  }

  // Get latest weight
  Future<double?> getLatestWeight() async {
    try {
      final now = DateTime.now();
      final lastMonth = now.subtract(const Duration(days: 30));

      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WEIGHT],
        startTime: lastMonth,
        endTime: now,
      );

      if (healthData.isNotEmpty) {
        final weightData = healthData
            .where((data) => data.type == HealthDataType.WEIGHT)
            .toList();
        
        if (weightData.isNotEmpty) {
          weightData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
          return (weightData.first.value as num).toDouble();
        }
      }
    } catch (error) {
      developer.log('Exception in getLatestWeight: $error');
    }

    return null;
  }

  // Get weight history for a date range
  Future<List<HealthDataPoint>> getWeightHistory(DateTime start, DateTime end) async {
    try {
      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WEIGHT],
        startTime: start,
        endTime: end,
      );

      return healthData
          .where((data) => data.type == HealthDataType.WEIGHT)
          .toList();
    } catch (error) {
      developer.log('Exception in getWeightHistory: $error');
    }

    return [];
  }

  // Write weight to health store
  Future<bool> writeWeight(double weight, DateTime date) async {
    try {
      return await _health.writeHealthData(
        value: weight,
        type: HealthDataType.WEIGHT,
        startTime: date,
        endTime: date,
        unit: HealthDataUnit.KILOGRAM,
      );
    } catch (error) {
      developer.log('Exception in writeWeight: $error');
    }

    return false;
  }

  // Get workouts for today
  Future<List<HealthDataPoint>> getTodayWorkouts() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);

    try {
      final healthData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT],
        startTime: midnight,
        endTime: now,
      );

      return healthData
          .where((data) => data.type == HealthDataType.WORKOUT)
          .toList();
    } catch (error) {
      developer.log('Exception in getTodayWorkouts: $error');
    }

    return [];
  }

  // Write workout to health store
  Future<bool> writeWorkout({
    required DateTime startTime,
    required DateTime endTime,
    required int durationMinutes,
    double? caloriesBurned,
  }) async {
    try {
      return await _health.writeWorkoutData(
        activityType: HealthWorkoutActivityType.STRENGTH_TRAINING,
        start: startTime,
        end: endTime,
        totalEnergyBurned: caloriesBurned?.toInt(),
        totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE,
      );
    } catch (error) {
      developer.log('Exception in writeWorkout: $error');
    }

    return false;
  }

  // Sync health data with local database
  Future<void> syncHealthData() async {
    try {
      // This will trigger a full sync of health data
      await getTodaySteps();
      await getTodayCalories();
      await getLatestWeight();
      await getTodayWorkouts();
    } catch (error) {
      developer.log('Exception in syncHealthData: $error');
    }
  }
}

