import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF8FAFB);
  static const Color lightPrimary = Color(0xFF10B981);
  static const Color lightSecondary = Color(0xFF34D399);
  static const Color lightAccent = Color(0xFF6EE7B7);
  static const Color lightText = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF6B7280);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F1F15);
  static const Color darkCard = Color(0xFF1A2E20);
  static const Color darkPrimary = Color(0xFF34D399);
  static const Color darkSecondary = Color(0xFF6EE7B7);
  static const Color darkAccent = Color(0xFF10B981);
  static const Color darkText = Color(0xFFE4E4E7);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  // Macro Colors
  static const Color proteinColor = Color(0xFF10B981);
  static const Color carbsColor = Color(0xFF34D399);
  static const Color fatsColor = Color(0xFF6EE7B7);
  static const Color fiberColor = Color(0xFF059669);
  static const Color caloriesColor = Color(0xFF10B981);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF6EE7B7), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
