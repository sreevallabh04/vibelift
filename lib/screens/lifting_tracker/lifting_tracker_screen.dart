import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import 'package:vibelift/core/constants.dart';
import 'package:vibelift/core/theme/app_colors.dart';
import 'package:vibelift/data/db/database.dart';
import 'package:vibelift/data/providers/database_provider.dart';
import 'package:vibelift/widgets/custom_button.dart';

class LiftingTrackerScreen extends ConsumerStatefulWidget {
  const LiftingTrackerScreen({super.key});

  @override
  ConsumerState<LiftingTrackerScreen> createState() =>
      _LiftingTrackerScreenState();
}

class _LiftingTrackerScreenState extends ConsumerState<LiftingTrackerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(databaseProvider).seedDefaultExercises();
    });
  }

  Future<void> _showStartWorkoutDialog() async {
    final pplSplit = AppConstants.workoutSplits['PPL']!;
    final today = (DateTime.now().weekday - 1) % 7;
    final suggestedWorkout = pplSplit[today];

    final TextEditingController nameController =
        TextEditingController(text: suggestedWorkout);

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
              const Text(
                'Start Workout',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Workout Name',
                  prefixIcon: Icon(CupertinoIcons.sportscourt),
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
                      text: 'Start',
                      onPressed: () async {
                        final database = ref.read(databaseProvider);
                        final sessionId = await database.insertWorkoutSession(
                          WorkoutSessionsCompanion.insert(
                            name: nameController.text.trim(),
                            date: DateTime.now(),
                          ),
                        );

                        if (context.mounted) {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  WorkoutSessionScreen(sessionId: sessionId),
                            ),
                          );
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

  @override
  Widget build(BuildContext context) {
    final workoutSessionsAsync = ref.watch(workoutSessionsProvider);
    final pplSplit = AppConstants.workoutSplits['PPL']!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ).createShader(bounds),
                        child: const Text(
                          'Workout Tracker',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Push Pull Legs Split',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF059669),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _showStartWorkoutDialog,
                        borderRadius: BorderRadius.circular(12),
                        child: const Icon(CupertinoIcons.add,
                            color: Color(0xFF10B981), size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PPL Weekly Split',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildWeeklySplit(pplSplit),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Recent Workouts',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    workoutSessionsAsync.when(
                      data: (sessions) {
                        if (sessions.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(CupertinoIcons.sportscourt,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('No workouts yet',
                                    style: TextStyle(fontSize: 18)),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: sessions.map((session) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 6),
                              child: Card(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            WorkoutSessionScreen(
                                                sessionId: session.id),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
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
                                              CupertinoIcons.flame_fill,
                                              color: Color(0xFF10B981)),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                session.name,
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateFormat(
                                                        'MMM d, yyyy • HH:mm')
                                                    .format(session.date),
                                                style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(CupertinoIcons.chevron_right,
                                            size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(Color(0xFF10B981))),
                      ),
                      error: (error, _) => Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('Error: $error'),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySplit(List<String> split) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: List.generate(7, (index) {
        final isToday = (DateTime.now().weekday - 1) % 7 == index;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isToday
                  ? const Color(0xFF10B981).withAlpha(26)
                  : const Color(0xFFF8FAFB),
              borderRadius: BorderRadius.circular(12),
              border: isToday
                  ? Border.all(color: const Color(0xFF10B981), width: 2)
                  : null,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    days[index],
                    style: TextStyle(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    split[index],
                    style: TextStyle(
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? const Color(0xFF10B981) : Colors.black87,
                    ),
                  ),
                ),
                if (isToday)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// Workout Session Detail Screen
class WorkoutSessionScreen extends ConsumerStatefulWidget {
  final int sessionId;

  const WorkoutSessionScreen({super.key, required this.sessionId});

  @override
  ConsumerState<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  Future<void> _addExercise() async {
    final database = ref.read(databaseProvider);
    final exercises = await database.getAllExercises();

    if (!mounted || exercises.isEmpty) return;

    final selectedExercise = await showDialog<Exercise>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Select Exercise',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 400,
                child: ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return ListTile(
                      title: Text(exercise.name),
                      subtitle: Text(
                          '${exercise.muscleGroup} • ${exercise.category}'),
                      onTap: () => Navigator.of(context).pop(exercise),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selectedExercise != null && mounted) {
      _showAddSetDialog(selectedExercise);
    }
  }

  Future<void> _showAddSetDialog(Exercise exercise) async {
    final TextEditingController weightController = TextEditingController();
    final TextEditingController repsController = TextEditingController();

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
              const Text(
                'Add Set',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                exercise.name,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  prefixIcon: Icon(CupertinoIcons.square_stack_3d_up),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Reps',
                  prefixIcon: Icon(CupertinoIcons.repeat),
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
                      text: 'Add',
                      onPressed: () async {
                        final weight = double.tryParse(weightController.text);
                        final reps = int.tryParse(repsController.text);

                        if (weight == null || reps == null) {
                          return;
                        }

                        final database = ref.read(databaseProvider);

                        final previousPR =
                            await database.getPersonalRecord(exercise.id);
                        final isPR =
                            previousPR == null || weight > previousPR.weight;

                        final existingSets =
                            await database.getSetsForSession(widget.sessionId);
                        final exerciseSets = existingSets
                            .where((s) => s.exerciseId == exercise.id)
                            .toList();
                        final setNumber = exerciseSets.length + 1;

                        await database.insertWorkoutSet(
                          WorkoutSetsCompanion.insert(
                            sessionId: widget.sessionId,
                            exerciseId: exercise.id,
                            setNumber: setNumber,
                            weight: weight,
                            reps: reps,
                            isPR: drift.Value(isPR),
                          ),
                        );

                        if (mounted) {
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                          if (isPR) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('New PR! ${weight}kg x $reps'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
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

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Workout Session'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.checkmark_alt),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<WorkoutSet>>(
        future: database.getSetsForSession(widget.sessionId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sets = snapshot.data!;

          if (sets.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.add_circled,
                      size: 64, color: Color(0xFF10B981)),
                  SizedBox(height: 16),
                  Text('No exercises yet', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Add your first exercise!'),
                ],
              ),
            );
          }

          final groupedSets = <int, List<WorkoutSet>>{};
          for (final set in sets) {
            groupedSets.putIfAbsent(set.exerciseId, () => []).add(set);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: groupedSets.length,
            itemBuilder: (context, index) {
              final exerciseId = groupedSets.keys.elementAt(index);
              final exerciseSets = groupedSets[exerciseId]!;

              return FutureBuilder<Exercise?>(
                future: database.select(database.exercises).get().then(
                      (exercises) => exercises.cast<Exercise?>().firstWhere(
                            (e) => e?.id == exerciseId,
                            orElse: () => null,
                          ),
                    ),
                builder: (context, exerciseSnapshot) {
                  if (!exerciseSnapshot.hasData ||
                      exerciseSnapshot.data == null) {
                    return const SizedBox();
                  }

                  final exercise = exerciseSnapshot.data!;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            ...exerciseSets.map((set) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Text('Set ${set.setNumber}'),
                                      const Spacer(),
                                      Text(
                                        '${set.weight}kg × ${set.reps}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      if (set.isPR) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                AppColors.success.withAlpha(26),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            'PR',
                                            style: TextStyle(
                                              color: AppColors.success,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExercise,
        icon: const Icon(CupertinoIcons.add),
        label: const Text('Add Exercise'),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
      ),
    );
  }
}

