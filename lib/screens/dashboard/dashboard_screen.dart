import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vibelift/core/constants.dart';
import 'package:vibelift/core/theme/app_colors.dart';
import 'package:vibelift/data/models/meal_macros.dart';
import 'package:vibelift/data/db/database.dart';
import 'package:vibelift/data/providers/database_provider.dart';
import 'package:vibelift/widgets/animated_progress_ring.dart';
import 'package:vibelift/widgets/stat_card.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayMealsAsync = ref.watch(todayMealsProvider);
    final latestWeightAsync = ref.watch(latestWeightProvider);
    final todayWorkoutsAsync = ref.watch(todayWorkoutSessionsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(todayMealsProvider);
            ref.invalidate(latestWeightProvider);
            ref.invalidate(todayWorkoutSessionsProvider);
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                  colors: [
                                    Color(0xFF10B981),
                                    Color(0xFF34D399)
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  'VibeLift',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat.yMMMMEEEEd().format(DateTime.now()),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withAlpha(26),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              CupertinoIcons.bell,
                              size: 24,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Today's Macros Section
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

                      return _buildMacrosCard(context, totalMacros);
                    },
                    loading: () => _buildMacrosCard(context, MealMacros.zero()),
                    error: (_, __) =>
                        _buildMacrosCard(context, MealMacros.zero()),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Weight Progress Chart
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ref.watch(weightEntriesProvider).when(
                        data: (entries) {
                          if (entries.length < 2) {
                            return const SizedBox();
                          }
                          return _buildWeightProgressCard(
                              entries.reversed.take(10).toList());
                        },
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Quick Stats Grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Stats',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: latestWeightAsync.when(
                              data: (weight) => StatCard(
                                title: 'Current Weight',
                                value: weight != null
                                    ? '${weight.weight.toStringAsFixed(1)} kg'
                                    : '--',
                                icon: CupertinoIcons.gauge,
                                color: const Color(0xFF10B981),
                              ),
                              loading: () => const StatCard(
                                title: 'Current Weight',
                                value: '--',
                                icon: CupertinoIcons.gauge,
                                color: Color(0xFF10B981),
                              ),
                              error: (_, __) => const StatCard(
                                title: 'Current Weight',
                                value: '--',
                                icon: CupertinoIcons.gauge,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: todayWorkoutsAsync.when(
                              data: (workouts) => StatCard(
                                title: 'Workouts',
                                value: '${workouts.length}',
                                subtitle: 'Today',
                                icon: CupertinoIcons.flame_fill,
                                color: const Color(0xFF10B981),
                              ),
                              loading: () => const StatCard(
                                title: 'Workouts',
                                value: '0',
                                subtitle: 'Today',
                                icon: CupertinoIcons.flame_fill,
                                color: Color(0xFF10B981),
                              ),
                              error: (_, __) => const StatCard(
                                title: 'Workouts',
                                value: '0',
                                subtitle: 'Today',
                                icon: CupertinoIcons.flame_fill,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Recent Meals
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Recent Meals',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                ),
              ),

              todayMealsAsync.when(
                data: (meals) {
                  if (meals.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              CupertinoIcons.tray,
                              size: 64,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withAlpha(77),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No meals logged yet',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final meal = meals[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        CupertinoIcons.circle_fill,
                                        size: 12,
                                        color: Color(0xFF10B981),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          meal.description,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        DateFormat('HH:mm')
                                            .format(meal.createdAt),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _buildMacroChip(
                                          'P: ${meal.protein.toStringAsFixed(0)}g',
                                          AppColors.proteinColor),
                                      const SizedBox(width: 8),
                                      _buildMacroChip(
                                          'C: ${meal.carbs.toStringAsFixed(0)}g',
                                          AppColors.carbsColor),
                                      const SizedBox(width: 8),
                                      _buildMacroChip(
                                          'F: ${meal.fats.toStringAsFixed(0)}g',
                                          AppColors.fatsColor),
                                      const Spacer(),
                                      Text(
                                        '${meal.calories.toStringAsFixed(0)} cal',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: meals.length > 3 ? 3 : meals.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacrosCard(BuildContext context, MealMacros macros) {
    final proteinProgress =
        (macros.protein / AppConstants.defaultProteinGoal).clamp(0.0, 1.0);
    final carbsProgress =
        (macros.carbs / AppConstants.defaultCarbsGoal).clamp(0.0, 1.0);
    final fatsProgress =
        (macros.fats / AppConstants.defaultFatsGoal).clamp(0.0, 1.0);
    final caloriesProgress =
        (macros.calories / AppConstants.defaultCaloriesGoal).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Nutrition',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AnimatedProgressRing(
                  progress: caloriesProgress,
                  color: AppColors.caloriesColor,
                  backgroundColor: AppColors.caloriesColor.withAlpha(26),
                  size: 100,
                  strokeWidth: 10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        macros.calories.toStringAsFixed(0),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Calories',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMacroRow(
                      context,
                      'Protein',
                      macros.protein,
                      AppConstants.defaultProteinGoal,
                      proteinProgress,
                      AppColors.proteinColor,
                    ),
                    const SizedBox(height: 12),
                    _buildMacroRow(
                      context,
                      'Carbs',
                      macros.carbs,
                      AppConstants.defaultCarbsGoal,
                      carbsProgress,
                      AppColors.carbsColor,
                    ),
                    const SizedBox(height: 12),
                    _buildMacroRow(
                      context,
                      'Fats',
                      macros.fats,
                      AppConstants.defaultFatsGoal,
                      fatsProgress,
                      AppColors.fatsColor,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow(
    BuildContext context,
    String label,
    double value,
    double goal,
    double progress,
    Color color,
  ) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${value.toStringAsFixed(0)}/${goal.toStringAsFixed(0)}g',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withAlpha(26),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildWeightProgressCard(List<WeightEntry> entries) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.chart_bar_alt_fill,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Weight Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${entries.first.weight.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: _buildWeightChart(entries),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightChart(List<WeightEntry> entries) {
    final spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weight);
    }).toList();

    final minWeight =
        entries.map((e) => e.weight).reduce((a, b) => a < b ? a : b);
    final maxWeight =
        entries.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
    final padding = (maxWeight - minWeight) * 0.2;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}kg',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= entries.length) return const Text('');
                final date = entries[value.toInt()].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('M/d').format(date),
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (entries.length - 1).toDouble(),
        minY: minWeight - padding,
        maxY: maxWeight + padding,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFF10B981),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981).withAlpha(77),
                  const Color(0xFF10B981).withAlpha(0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
