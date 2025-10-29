import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors - Earthy & Natural
  static const Color lightBackground = Color(0xFFF5F1E8); // Warm beige
  static const Color lightCard = Color(0xFFFFFFFF); // Pure white cards
  static const Color lightPrimary = Color(0xFF2D5F4F); // Dark forest green
  static const Color lightSecondary = Color(0xFF4A7C6B); // Medium green
  static const Color lightAccent = Color(0xFF8FBC8F); // Soft sage green
  static const Color lightText = Color(0xFF1A1A1A); // Almost black
  static const Color lightTextSecondary = Color(0xFF6B6B6B); // Gray

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkCard = Color(0xFF2A2A2A);
  static const Color darkPrimary = Color(0xFF4A7C6B);
  static const Color darkSecondary = Color(0xFF6B9D8A);
  static const Color darkAccent = Color(0xFF8FBC8F);
  static const Color darkText = Color(0xFFF5F1E8);
  static const Color darkTextSecondary = Color(0xFFB8B8B8);

  // Macro Colors - Natural tones
  static const Color proteinColor = Color(0xFF8FBC8F); // Sage green
  static const Color carbsColor = Color(0xFFE8B4A0); // Warm terracotta
  static const Color fatsColor = Color(0xFFD4A574); // Golden tan
  static const Color fiberColor = Color(0xFFA8C5A0); // Light sage
  static const Color caloriesColor = Color(0xFF2D5F4F); // Forest green

  // Status Colors
  static const Color success = Color(0xFF4A7C6B);
  static const Color warning = Color(0xFFE8B4A0);
  static const Color error = Color(0xFFD47B7B);
  static const Color info = Color(0xFF6B8FA3);

  // Additional UI Colors
  static const Color creamAccent = Color(0xFFFAF7F0);
  static const Color beigeLight = Color(0xFFEFE9DC);
  static const Color terracotta = Color(0xFFCB997E);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2D5F4F), Color(0xFF4A7C6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFF5F1E8), Color(0xFFFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF8FBC8F), Color(0xFFA8C5A0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFAF7F0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
