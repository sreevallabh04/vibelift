import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibelift/data/services/groq_service.dart';

final groqServiceProvider = Provider<GroqService>((ref) {
  return GroqService();
});
