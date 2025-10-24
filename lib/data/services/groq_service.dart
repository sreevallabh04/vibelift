import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vibelift/core/api_config.dart';
import 'package:vibelift/core/constants.dart';
import 'package:vibelift/data/models/meal_macros.dart';

class GroqService {
  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  /// Analyzes a meal description and returns estimated macros using Groq AI
  Future<MealMacros> analyzeMeal(String mealDescription) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.groqApiKey}',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a nutrition expert. Analyze meals and return ONLY valid JSON with exact nutritional values. Format: {"protein": number, "carbs": number, "fats": number, "fiber": number, "calories": number}. Use typical portion sizes and be accurate.'
            },
            {
              'role': 'user',
              'content':
                  'Analyze this meal and return nutritional values in JSON format: "$mealDescription"'
            }
          ],
          'temperature': 0.3,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        // Extract JSON from response
        String jsonText = content.trim();

        // Remove markdown code blocks if present
        if (jsonText.startsWith('```json')) {
          jsonText = jsonText.substring(7);
        } else if (jsonText.startsWith('```')) {
          jsonText = jsonText.substring(3);
        }

        if (jsonText.endsWith('```')) {
          jsonText = jsonText.substring(0, jsonText.length - 3);
        }

        jsonText = jsonText.trim();

        // Parse JSON response
        final Map<String, dynamic> jsonResponse = json.decode(jsonText);

        return MealMacros.fromJson(jsonResponse);
      } else {
        throw Exception('API returned status code: ${response.statusCode}');
      }
    } catch (e) {
      // On error, return reasonable estimates based on common meals
      // This ensures the app remains functional even if API fails
      return _estimateMacros(mealDescription);
    }
  }

  /// Fallback estimation when API fails
  MealMacros _estimateMacros(String description) {
    final lower = description.toLowerCase();

    // Simple keyword-based estimation
    double protein = 20.0;
    double carbs = 30.0;
    double fats = 10.0;
    double fiber = 4.0;

    // Adjust based on keywords
    if (lower.contains('chicken') ||
        lower.contains('meat') ||
        lower.contains('fish')) {
      protein += 15.0;
    }
    if (lower.contains('egg')) {
      protein += 6.0;
      fats += 5.0;
    }
    if (lower.contains('rice') ||
        lower.contains('bread') ||
        lower.contains('pasta')) {
      carbs += 30.0;
    }
    if (lower.contains('chapati') || lower.contains('roti')) {
      carbs += 15.0;
    }
    if (lower.contains('oil') ||
        lower.contains('butter') ||
        lower.contains('fried')) {
      fats += 10.0;
    }
    if (lower.contains('vegetable') || lower.contains('salad')) {
      fiber += 3.0;
    }

    final calories = (protein * 4) + (carbs * 4) + (fats * 9);

    return MealMacros(
      protein: protein,
      carbs: carbs,
      fats: fats,
      fiber: fiber,
      calories: calories,
    );
  }

  /// Generates a workout split based on fitness goal
  Future<List<String>> generateWorkoutSplit(String goal) async {
    return AppConstants.workoutSplits[goal] ??
        AppConstants.workoutSplits['Bulk']!;
  }

  /// Suggests exercises for a given workout category
  Future<List<String>> suggestExercises(String category, int count) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiConfig.groqApiKey}',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'user',
              'content':
                  'Suggest $count specific exercises for a "$category" workout. Return ONLY a JSON array of exercise names: ["Exercise 1", "Exercise 2", ...]'
            }
          ],
          'temperature': 0.5,
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        String jsonText = content.trim();

        if (jsonText.startsWith('```json')) {
          jsonText = jsonText.substring(7);
        } else if (jsonText.startsWith('```')) {
          jsonText = jsonText.substring(3);
        }

        if (jsonText.endsWith('```')) {
          jsonText = jsonText.substring(0, jsonText.length - 3);
        }

        jsonText = jsonText.trim();

        final List<dynamic> exercises = json.decode(jsonText);
        return exercises.map((e) => e.toString()).toList();
      }
    } catch (e) {
      // Fallback to defaults
    }

    return _getDefaultExercises(category, count);
  }

  List<String> _getDefaultExercises(String category, int count) {
    final defaults = {
      'Push': [
        'Bench Press',
        'Overhead Press',
        'Tricep Dips',
        'Lateral Raises'
      ],
      'Pull': ['Pull-ups', 'Barbell Rows', 'Deadlifts', 'Bicep Curls'],
      'Legs': ['Squats', 'Leg Press', 'Romanian Deadlifts', 'Calf Raises'],
      'Upper': ['Bench Press', 'Rows', 'Overhead Press', 'Pull-ups'],
      'Lower': ['Squats', 'Deadlifts', 'Leg Press', 'Lunges'],
    };

    final exercises = defaults[category] ?? defaults['Push']!;
    return exercises.take(count).toList();
  }
}
