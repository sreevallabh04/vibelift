import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:vibelift/core/theme/app_colors.dart';
import 'package:vibelift/data/db/database.dart';
import 'package:vibelift/data/models/meal_macros.dart';
import 'package:vibelift/data/providers/database_provider.dart';
import 'package:vibelift/data/providers/health_provider.dart';
import 'package:vibelift/screens/health_connect/health_connect_screen.dart';

final todayMealsProvider = StreamProvider<List<Meal>>((ref) {
  final db = ref.watch(databaseProvider);
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  return db.watchMealsForDate(startOfDay);
});

final weightEntriesProvider = StreamProvider<List<WeightEntry>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllWeightEntries();
});

final latestWeightProvider = StreamProvider<WeightEntry?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchLatestWeight();
});

final todayWorkoutSessionsProvider =
    StreamProvider<List<WorkoutSession>>((ref) {
  final db = ref.watch(databaseProvider);
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  return db.watchWorkoutSessionsForDate(startOfDay);
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayMealsAsync = ref.watch(todayMealsProvider);
    final latestWeightAsync = ref.watch(latestWeightProvider);
    final todayStepsAsync = ref.watch(todayStepsProvider);
    final todayCaloriesAsync = ref.watch(todayCaloriesProvider);
    final latestHealthWeightAsync = ref.watch(latestHealthWeightProvider);
    final todayWorkoutsAsync = ref.watch(todayWorkoutsProvider);
    final streakAsync = ref.watch(currentStreakProvider);
    // Health stats providers are available; wire into UI where needed

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todayMealsProvider);
            ref.invalidate(weightEntriesProvider);
            ref.invalidate(latestWeightProvider);
            ref.invalidate(todayWorkoutSessionsProvider);
          },
          child: CustomScrollView(
            slivers: [
              // Header Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.lightPrimary,
                                width: 2,
                              ),
                            ),
                            child: const CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.lightPrimary,
                              child: Icon(
                                CupertinoIcons.person_fill,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                ),
                                Text(
                                  DateFormat.yMMMMEEEEd()
                                      .format(DateTime.now()),
                                  style: const TextStyle(
                                    color: AppColors.lightTextSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          streakAsync.when(
                            data: (streak) => _buildStreakBadge(streak),
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const HealthConnectScreen(),
                                ),
                              );
                              ref.invalidate(todayStepsProvider);
                              ref.invalidate(todayCaloriesProvider);
                              ref.invalidate(latestHealthWeightProvider);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                CupertinoIcons.heart_fill,
                                color: AppColors.terracotta,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // Health Stats (Steps & Calories)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: todayStepsAsync.when(
                          data: (steps) => _buildHealthStatCard(
                            context,
                            'Steps',
                            steps.toString(),
                            CupertinoIcons.flame_fill,
                            AppColors.proteinColor,
                          ),
                          loading: () => _buildHealthStatCard(
                            context,
                            'Steps',
                            '...',
                            CupertinoIcons.flame_fill,
                            AppColors.proteinColor,
                          ),
                          error: (_, __) => _buildHealthStatCard(
                            context,
                            'Steps',
                            '0',
                            CupertinoIcons.flame_fill,
                            AppColors.proteinColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: todayCaloriesAsync.when(
                          data: (calories) => _buildHealthStatCard(
                            context,
                            'Burned',
                            '${calories.toInt()} kcal',
                            CupertinoIcons.bolt_fill,
                            AppColors.terracotta,
                          ),
                          loading: () => _buildHealthStatCard(
                            context,
                            'Burned',
                            '... kcal',
                            CupertinoIcons.bolt_fill,
                            AppColors.terracotta,
                          ),
                          error: (_, __) => _buildHealthStatCard(
                            context,
                            'Burned',
                            '0 kcal',
                            CupertinoIcons.bolt_fill,
                            AppColors.terracotta,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Weight Card (prefers local log; falls back to Health)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: latestWeightAsync.when(
                    data: (weight) {
                      if (weight != null) {
                        return _buildWeightCard(context, weight, ref);
                      }
                      return latestHealthWeightAsync.when(
                        data: (hw) {
                          final fallback = hw == null
                              ? null
                              : WeightEntry(
                                  id: -1,
                                  weight: hw,
                                  date: DateTime.now(),
                                  notes: null,
                                );
                          return _buildWeightCard(context, fallback, ref);
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (_, __) => _buildWeightCard(context, null, ref),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const SizedBox(),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Activity Summary Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: todayMealsAsync.when(
                    data: (meals) {
                      final totalMacros = meals.fold<MealMacros>(
                        MealMacros.zero(),
                        (sum, meal) =>
                            sum +
                            MealMacros(
                              protein: meal.protein,
                              carbs: meal.carbs,
                              fats: meal.fats,
                              fiber: meal.fiber,
                              calories: meal.calories,
                            ),
                      );
                      return _buildActivitySummaryCard(context, totalMacros);
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, __) =>
                        _buildActivitySummaryCard(context, MealMacros.zero()),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Removed mock quick stats; replaced by health stats above
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Today's Goals Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            CupertinoIcons.checkmark_shield_fill,
                            color: AppColors.lightPrimary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Today\'s Goals',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(CupertinoIcons.add_circled_solid),
                        color: AppColors.lightPrimary,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Goal Items (dynamic)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      todayWorkoutsAsync.when(
                        data: (w) =>
                            _buildGoalItem(context, 'Workout today', w > 0),
                        loading: () =>
                            _buildGoalItem(context, 'Workout today', false),
                        error: (_, __) =>
                            _buildGoalItem(context, 'Workout today', false),
                      ),
                      const SizedBox(height: 8),
                      todayStepsAsync.when(
                        data: (s) =>
                            _buildGoalItem(context, '8k steps', s >= 8000),
                        loading: () =>
                            _buildGoalItem(context, '8k steps', false),
                        error: (_, __) =>
                            _buildGoalItem(context, '8k steps', false),
                      ),
                      const SizedBox(height: 8),
                      latestWeightAsync.when(
                        data: (w) {
                          final bool done = w != null &&
                              DateUtils.isSameDay(w.date, DateTime.now());
                          return _buildGoalItem(context, 'Log weight', done);
                        },
                        loading: () =>
                            _buildGoalItem(context, 'Log weight', false),
                        error: (_, __) =>
                            _buildGoalItem(context, 'Log weight', false),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakBadge(int streak) {
    if (streak <= 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            '🔥',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 4),
          Text(
            '$streak',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightCard(
      BuildContext context, WeightEntry? weight, WidgetRef ref) {
    final weightEntriesAsync = ref.watch(weightEntriesProvider);

    return weightEntriesAsync.when(
      data: (entries) {
        if (entries.length < 2) {
          return _buildSimpleWeightCard(context, weight);
        }
        return _buildWeightChartCard(context, weight, entries);
      },
      loading: () => _buildSimpleWeightCard(context, weight),
      error: (_, __) => _buildSimpleWeightCard(context, weight),
    );
  }

  Widget _buildSimpleWeightCard(BuildContext context, WeightEntry? weight) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightPrimary.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                CupertinoIcons.gauge_badge_plus,
                color: AppColors.lightPrimary,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Weight',
                    style: TextStyle(
                      color: AppColors.lightTextSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weight != null
                        ? '${weight.weight.toStringAsFixed(1)} kg'
                        : 'Not logged',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChartCard(
      BuildContext context, WeightEntry? weight, List<WeightEntry> entries) {
    final recentEntries = entries.reversed.take(7).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weight Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weight != null
                          ? '${weight.weight.toStringAsFixed(1)} kg'
                          : 'No data',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Week',
                    style: TextStyle(
                      color: AppColors.lightPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: _buildWeightBarChart(recentEntries),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightBarChart(List<WeightEntry> entries) {
    if (entries.isEmpty) return const SizedBox();

    final weights = entries.map((e) => e.weight).toList();
    final maxWeight = weights.reduce((a, b) => a > b ? a : b);
    final minWeight = weights.reduce((a, b) => a < b ? a : b);
    final range = maxWeight - minWeight;
    final padding = range * 0.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxWeight + padding,
        minY: minWeight - padding,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < entries.length) {
                  final day = DateFormat('E').format(entries[index].date);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      day.substring(0, 3),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: entries.asMap().entries.map((entry) {
          final index = entry.key;
          final weight = entry.value.weight;
          final isToday = entry.value.date.day == DateTime.now().day;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: weight,
                color: isToday ? AppColors.terracotta : AppColors.lightPrimary,
                width: 16,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivitySummaryCard(BuildContext context, MealMacros macros) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Activity Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            CupertinoIcons.flame_fill,
                            color: AppColors.terracotta,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Calories',
                            style: TextStyle(
                              color: AppColors.lightTextSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${macros.calories.toInt()}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'kcal',
                        style: TextStyle(
                          color: AppColors.lightTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: (macros.calories / 2000).clamp(0.0, 1.0),
                        strokeWidth: 8,
                        backgroundColor: AppColors.beigeLight,
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.lightPrimary),
                      ),
                      Center(
                        child: Text(
                          '${((macros.calories / 2000) * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lightPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMacroIndicator(
                    'Protein', macros.protein, AppColors.proteinColor),
                _buildMacroIndicator(
                    'Carbs', macros.carbs, AppColors.carbsColor),
                _buildMacroIndicator('Fats', macros.fats, AppColors.fatsColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroIndicator(String label, double value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${value.toInt()}g',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.lightTextSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // Removed legacy quick stat card used for mock data

  Widget _buildGoalItem(BuildContext context, String title, bool isComplete) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete ? AppColors.lightPrimary : AppColors.beigeLight,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isComplete ? AppColors.lightPrimary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isComplete
                    ? AppColors.lightPrimary
                    : AppColors.lightTextSecondary,
                width: 2,
              ),
            ),
            child: Icon(
              isComplete ? Icons.check : null,
              color: Colors.white,
              size: 12,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                decoration: isComplete ? TextDecoration.lineThrough : null,
                color: isComplete
                    ? AppColors.lightTextSecondary
                    : AppColors.lightText,
              ),
            ),
          ),
          if (isComplete)
            const Text(
              'Complete',
              style: TextStyle(
                color: AppColors.lightPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHealthStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
