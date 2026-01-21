import 'package:flutter/material.dart';

/// ===============================
/// COLORS
/// ===============================
class AppColors {
  // Primary Theme
  static const Color primary = Color(0xFF7B3FE4);
  static const Color secondary = Color(0xFFFFC857);
  static const Color accent = Color(0xFFF857C3);

  // Backgrounds
  static const Color scaffoldBg = Color(0xFFF6F1FF);
  static const Color cardBg = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color textLight = Color(0xFF9E9E9E);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);

  // Borders & Divider
  static const Color border = Color(0xFFE0E0E0);

  // Dark Theme Colors
  static const Color darkScaffoldBg = Color(0xFF121212); // Deep Black/Dark Grey
  static const Color darkCardBg = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
}

/// ===============================
/// TEXT STYLES
/// ===============================
class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle subHeading = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textLight,
  );

  static const TextStyle price = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}