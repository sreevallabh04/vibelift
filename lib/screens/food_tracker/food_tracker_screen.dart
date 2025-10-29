import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:vibelift/core/theme/app_colors.dart';
import 'package:vibelift/data/db/database.dart';
import 'package:vibelift/data/providers/database_provider.dart';
import 'package:vibelift/data/providers/groq_provider.dart';
import 'package:vibelift/widgets/custom_button.dart';
import 'package:vibelift/widgets/lottie_loader.dart';

class FoodTrackerScreen extends ConsumerStatefulWidget {
  const FoodTrackerScreen({super.key});

  @override
  ConsumerState<FoodTrackerScreen> createState() => _FoodTrackerScreenState();
}

class _FoodTrackerScreenState extends ConsumerState<FoodTrackerScreen> {
  final TextEditingController _mealController = TextEditingController();
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _mealController.dispose();
    super.dispose();
  }

  Future<void> _analyzeMeal() async {
    if (_mealController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a meal description')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    try {
      final groqService = ref.read(groqServiceProvider);
      final macros = await groqService.analyzeMeal(_mealController.text.trim());

      if (!mounted) return;

      // Show result dialog
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (context) => _buildMacrosResultDialog(context, macros),
      );

      if (shouldSave == true) {
        final database = ref.read(databaseProvider);
        await database.insertMeal(
          MealsCompanion.insert(
            description: _mealController.text.trim(),
            protein: macros.protein,
            carbs: macros.carbs,
            fats: macros.fats,
            fiber: macros.fiber,
            calories: macros.calories,
            createdAt: DateTime.now(),
          ),
        );

        if (mounted) {
          showSuccessAnimation(context, message: 'Meal logged successfully!');
          _mealController.clear();
          ref.invalidate(todayMealsProvider);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing meal: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  Widget _buildMacrosResultDialog(BuildContext context, macros) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: AppColors.success,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Meal Analysis',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            _buildMacroResultRow(
                'Protein', macros.protein, 'g', AppColors.proteinColor),
            const SizedBox(height: 12),
            _buildMacroResultRow(
                'Carbs', macros.carbs, 'g', AppColors.carbsColor),
            const SizedBox(height: 12),
            _buildMacroResultRow('Fats', macros.fats, 'g', AppColors.fatsColor),
            const SizedBox(height: 12),
            _buildMacroResultRow(
                'Fiber', macros.fiber, 'g', AppColors.fiberColor),
            const SizedBox(height: 12),
            _buildMacroResultRow(
                'Calories', macros.calories, 'kcal', AppColors.caloriesColor),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
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
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroResultRow(
      String label, double value, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mealsAsync = ref.watch(mealsProvider);
    final favoriteMealsAsync = ref.watch(favoriteMealsProvider);

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
                    'Food Tracker',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const Spacer(),
                  CustomIconButton(
                    icon: CupertinoIcons.heart_fill,
                    onPressed: () {
                      // Show favorites
                    },
                  ),
                ],
              ),
            ),

            // Input Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'What did you eat?',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _mealController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText:
                              'e.g., 2 chapatis, dal, rice, chicken curry',
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(
                        text: _isAnalyzing ? 'Analyzing...' : 'Analyze Meal',
                        onPressed: _analyzeMeal,
                        isLoading: _isAnalyzing,
                        icon: CupertinoIcons.sparkles,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Favorites Section
            if (favoriteMealsAsync.hasValue &&
                favoriteMealsAsync.value!.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Favorites',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: favoriteMealsAsync.value!.length,
                  itemBuilder: (context, index) {
                    final meal = favoriteMealsAsync.value![index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: InkWell(
                        onTap: () {
                          _mealController.text = meal.description;
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(CupertinoIcons.heart_fill,
                                  color: AppColors.error),
                              const SizedBox(height: 4),
                              Text(
                                meal.description,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Meal History
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Recent Meals',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: mealsAsync.when(
                data: (meals) {
                  if (meals.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start tracking your nutrition!',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: meals.length,
                    itemBuilder: (context, index) {
                      final meal = meals[index];
                      return Dismissible(
                        key: Key(meal.id.toString()),
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
                          await database.deleteMeal(meal.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
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
                                      IconButton(
                                        icon: Icon(
                                          meal.isFavorite
                                              ? CupertinoIcons.heart_fill
                                              : CupertinoIcons.heart,
                                          color: meal.isFavorite
                                              ? AppColors.error
                                              : null,
                                        ),
                                        onPressed: () async {
                                          final database =
                                              ref.read(databaseProvider);
                                          await database.updateMeal(
                                            meal.copyWith(
                                                isFavorite: !meal.isFavorite),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat('MMM d, yyyy • HH:mm')
                                        .format(meal.createdAt),
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildMacroChip(
                                          'P: ${meal.protein.toStringAsFixed(0)}g',
                                          AppColors.proteinColor),
                                      _buildMacroChip(
                                          'C: ${meal.carbs.toStringAsFixed(0)}g',
                                          AppColors.carbsColor),
                                      _buildMacroChip(
                                          'F: ${meal.fats.toStringAsFixed(0)}g',
                                          AppColors.fatsColor),
                                      _buildMacroChip(
                                          'Fiber: ${meal.fiber.toStringAsFixed(0)}g',
                                          AppColors.fiberColor),
                                      _buildMacroChip(
                                          '${meal.calories.toStringAsFixed(0)} kcal',
                                          AppColors.caloriesColor),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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

  Widget _buildMacroChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
}
