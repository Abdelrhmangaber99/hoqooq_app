import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors (Shared)
  static const Color primary = Color(0xFFD4AF37); // Gold
  static const Color primaryLight = Color(0xFFF1D27C);
  static const Color primaryDark = Color(0xFF997A1C);

  // Dark Mode Colors
  static const Color background = Color(0xFF12110F);
  static const Color surface = Color(0xFF1C1B19);
  static const Color surfaceLight = Color(0xFF2C2B29);

  // Light Mode Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceGray = Color(0xFFF0F0F0);

  // Text Colors (Shared/Dynamic)
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textPrimaryLight = Color(0xFF12110F);
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color textHint = Color(0xFF666666);
  static const Color textOnPrimary = Color(0xFF12110F);

  // Functional Colors
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFF997A1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [Color(0xFF1C1B19), Color(0xFF12110F)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
