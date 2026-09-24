import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

import 'app_radius.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _theme(Brightness.light);
  static ThemeData get darkTheme => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final background = dark ? AppColors.ink900 : AppColors.paper;
    final surface = dark ? AppColors.ink800 : Colors.white;
    final foreground = dark ? Colors.white : AppColors.ink900;
    final muted = dark ? AppColors.ink300 : AppColors.ink500;
    final line = dark ? AppColors.ink600 : AppColors.paperLine;

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.brass500,
        brightness: brightness,
        primary: AppColors.brass500,
        secondary: AppColors.ink600,
        surface: surface,
        error: AppColors.rust500,
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(base.textTheme).apply(
        bodyColor: foreground,
        displayColor: foreground,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: foreground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        shape: Border(bottom: BorderSide(color: line)),
        titleTextStyle: AppTypography.h3.copyWith(color: foreground),
        iconTheme: IconThemeData(color: muted),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: AppColors.ink800.withValues(alpha: .06),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.medium,
          side: BorderSide(color: line),
        ),
      ),
      dividerColor: line,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brass500,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.brass300,
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
          textStyle: AppTypography.labelLarge.copyWith(color: Colors.white),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.medium),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          side: BorderSide(color: line),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.medium),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.brass600),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? AppColors.ink800 : AppColors.paper,
        hintStyle: TextStyle(color: dark ? AppColors.ink300 : AppColors.ink300),
        labelStyle: TextStyle(color: muted),
        floatingLabelStyle: const TextStyle(color: AppColors.brass700),
        border: const OutlineInputBorder(borderRadius: AppRadius.medium),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(color: AppColors.brass500, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(color: AppColors.rust500),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: dark ? AppColors.ink600 : AppColors.paperSoft,
        side: BorderSide(color: line),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.small),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.brass100,
        labelTextStyle: WidgetStatePropertyAll(
          AppTypography.labelMedium.copyWith(color: foreground),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: AppColors.brass600,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink800,
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: Colors.white),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.medium),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
