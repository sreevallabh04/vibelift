import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:vibelift/core/theme/app_colors.dart';
import 'package:vibelift/data/db/database.dart';
import 'package:vibelift/data/providers/database_provider.dart';
import 'package:vibelift/data/providers/settings_provider.dart';
import 'package:vibelift/widgets/custom_button.dart';
import 'package:vibelift/widgets/lottie_loader.dart';

class WeightTrackerScreen extends ConsumerStatefulWidget {
  const WeightTrackerScreen({super.key});

  @override
  ConsumerState<WeightTrackerScreen> createState() =>
      _WeightTrackerScreenState();
}

class _WeightTrackerScreenState extends ConsumerState<WeightTrackerScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _showAddWeightDialog() async {
    _weightController.clear();
    _notesController.clear();

    return showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Log Weight',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  prefixIcon: Icon(CupertinoIcons.gauge),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(CupertinoIcons.text_badge_checkmark),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Save',
                      onPressed: _saveWeight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveWeight() async {
    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid weight')),
      );
      return;
    }

    final database = ref.read(databaseProvider);
    await database.insertWeightEntry(
      WeightEntriesCompanion.insert(
        weight: weight,
        date: DateTime.now(),
        notes: drift.Value(_notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim()),
      ),
    );

    if (mounted) {
      Navigator.of(context).pop();
      showSuccessAnimation(context, message: 'Weight logged successfully!');
      ref.invalidate(weightEntriesProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weightEntriesAsync = ref.watch(weightEntriesProvider);
    final goalWeight = ref.watch(goalWeightProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text(
                    'Weight Tracker',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const Spacer(),
                  CustomIconButton(
                    icon: CupertinoIcons.add,
                    onPressed: _showAddWeightDialog,
                  ),
                ],
              ),
            ),

            Expanded(
              child: weightEntriesAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.gauge,
                            size: 64,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withAlpha(77),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No weight entries yet',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start tracking your progress!',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  final latestEntry = entries.first;
                  final oldestEntry = entries.last;
                  final weightChange = latestEntry.weight - oldestEntry.weight;
                  final progressPercent = goalWeight != null
                      ? ((oldestEntry.weight - latestEntry.weight) /
                          (oldestEntry.weight - goalWeight) *
                          100)
                      : 0.0;

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Stats Cards
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Current',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${latestEntry.weight.toStringAsFixed(1)} kg',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displaySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF10B981),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        Text(
                                          'Change',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              weightChange > 0
                                                  ? CupertinoIcons.arrow_up
                                                  : CupertinoIcons.arrow_down,
                                              color: weightChange > 0
                                                  ? AppColors.warning
                                                  : AppColors.success,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${weightChange.abs().toStringAsFixed(1)} kg',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: weightChange > 0
                                                        ? AppColors.warning
                                                        : AppColors.success,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Goal Progress (if goal is set)
                        if (goalWeight != null) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Goal Progress',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                        const Spacer(),
                                        Text(
                                          'Goal: ${goalWeight.toStringAsFixed(1)} kg',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: (progressPercent / 100)
                                            .clamp(0.0, 1.0),
                                        backgroundColor: const Color(0xFF10B981)
                                            .withAlpha(26),
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                                Color(0xFF10B981)),
                                        minHeight: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${progressPercent.toStringAsFixed(1)}% to goal',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Weight Chart
                        if (entries.length >= 2) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Weight Trend',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    const SizedBox(height: 20),
                                    SizedBox(
                                      height: 200,
                                      child: _buildWeightChart(
                                          entries.reversed.toList()),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Weight History
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'History',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: entries.length,
                          itemBuilder: (context, index) {
                            final entry = entries[index];
                            final previousEntry = index < entries.length - 1
                                ? entries[index + 1]
                                : null;
                            final difference = previousEntry != null
                                ? entry.weight - previousEntry.weight
                                : 0.0;

                            return Dismissible(
                              key: Key(entry.id.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(CupertinoIcons.delete,
                                    color: Colors.white),
                              ),
                              onDismissed: (_) async {
                                final database = ref.read(databaseProvider);
                                await database.deleteWeightEntry(entry.id);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981)
                                                .withAlpha(26),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            CupertinoIcons.gauge,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${entry.weight.toStringAsFixed(1)} kg',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateFormat(
                                                        'MMM d, yyyy • HH:mm')
                                                    .format(entry.date),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium,
                                              ),
                                              if (entry.notes != null) ...[
                                                const SizedBox(height: 4),
                                                Text(
                                                  entry.notes!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontStyle:
                                                            FontStyle.italic,
                                                      ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        if (previousEntry != null &&
                                            difference != 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: (difference > 0
                                                      ? AppColors.warning
                                                      : AppColors.success)
                                                  .withAlpha(26),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  difference > 0
                                                      ? CupertinoIcons.arrow_up
                                                      : CupertinoIcons
                                                          .arrow_down,
                                                  size: 16,
                                                  color: difference > 0
                                                      ? AppColors.warning
                                                      : AppColors.success,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  difference
                                                      .abs()
                                                      .toStringAsFixed(1),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: difference > 0
                                                        ? AppColors.warning
                                                        : AppColors.success,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
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
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).dividerColor.withAlpha(26),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= entries.length) return const Text('');
                final date = entries[value.toInt()].date;
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('M/d').format(date),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 42,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(0)}kg',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 10),
                );
              },
            ),
          ),
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
            isStrokeCapRound: true,
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
                  AppColors.lightPrimary.withAlpha(77),
                  AppColors.lightPrimary.withAlpha(0),
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
