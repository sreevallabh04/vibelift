import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibelift/core/constants.dart';
import 'package:vibelift/core/theme/app_colors.dart';
import 'package:vibelift/data/providers/settings_provider.dart';
import 'package:vibelift/widgets/custom_button.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final fitnessGoal = ref.watch(fitnessGoalProvider);
    final goalWeight = ref.watch(goalWeightProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Settings',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),

              // App Settings Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'App Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(CupertinoIcons.moon_stars),
                        title: const Text('Dark Mode'),
                        trailing: Switch(
                          value: themeMode == ThemeMode.dark,
                          onChanged: (value) {
                            ref.read(themeModeProvider.notifier).setThemeMode(
                                  value ? ThemeMode.dark : ThemeMode.light,
                                );
                          },
                          activeColor: const Color(0xFF10B981),
                        ),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(CupertinoIcons.bell),
                        title: const Text('Notifications'),
                        subtitle: const Text('Meal and workout reminders'),
                        trailing: Switch(
                          value: false,
                          onChanged: (value) {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Fitness Goals Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Fitness Goals',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(CupertinoIcons.flag),
                        title: const Text('Fitness Goal'),
                        subtitle: Text(fitnessGoal),
                        trailing: const Icon(CupertinoIcons.chevron_right),
                        onTap: () => _showGoalPicker(context, ref),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(CupertinoIcons.chart_bar),
                        title: const Text('Goal Weight'),
                        subtitle: Text(goalWeight != null
                            ? '${goalWeight.toStringAsFixed(1)} kg'
                            : 'Not set'),
                        trailing: const Icon(CupertinoIcons.pencil),
                        onTap: () => _showGoalWeightDialog(context, ref),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // About Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'About',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  child: Column(
                    children: [
                      const ListTile(
                        leading: Icon(CupertinoIcons.info),
                        title: Text('App Version'),
                        subtitle: Text(AppConstants.appVersion),
                      ),
                      const Divider(height: 1),
                      const ListTile(
                        leading: Icon(CupertinoIcons.heart_fill),
                        title: Text('Made with'),
                        subtitle: Text('Flutter & Gemini AI'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(CupertinoIcons.book),
                        title: const Text('Privacy Policy'),
                        trailing: const Icon(CupertinoIcons.chevron_right),
                        onTap: () {
                          //
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Data Management
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Data',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(CupertinoIcons.cloud_upload),
                        title: const Text('Backup Data'),
                        subtitle: const Text('Save your data to the cloud'),
                        trailing: const Icon(CupertinoIcons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Backup feature coming soon!')),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(CupertinoIcons.arrow_down_doc,
                            color: AppColors.warning),
                        title: const Text('Export Data'),
                        subtitle: const Text('Download your data as JSON'),
                        trailing: const Icon(CupertinoIcons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Export feature coming soon!')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _showGoalPicker(BuildContext context, WidgetRef ref) {
    showDialog(
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
                'Select Fitness Goal',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              ...AppConstants.fitnessGoals.map((goal) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CustomButton(
                    text: goal,
                    onPressed: () {
                      ref.read(fitnessGoalProvider.notifier).setGoal(goal);
                      Navigator.of(context).pop();
                    },
                    isSecondary: goal != 'Bulk',
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showGoalWeightDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController controller = TextEditingController(
      text: ref.read(goalWeightProvider)?.toString() ?? '',
    );

    showDialog(
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
                'Set Goal Weight',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Goal Weight (kg)',
                  prefixIcon: Icon(CupertinoIcons.chart_bar),
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
                      onPressed: () {
                        final weight = double.tryParse(controller.text);
                        if (weight != null && weight > 0) {
                          ref
                              .read(goalWeightProvider.notifier)
                              .setGoalWeight(weight);
                          Navigator.of(context).pop();
                        }
                      },
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
}
