import 'package:flutter/material.dart';

/// Shared Hoqooq palette. Values mirror the React frontend Tailwind tokens.
class AppColors {
  AppColors._();

  static const ink900 = Color(0xFF0B192F);
  static const ink800 = Color(0xFF10233F);
  static const ink700 = Color(0xFF182D4B);
  static const ink600 = Color(0xFF233A5C);
  static const ink500 = Color(0xFF374F73);
  static const ink400 = Color(0xFF5A7093);
  static const ink300 = Color(0xFF8B9EB7);
  static const ink200 = Color(0xFFC4CDDB);
  static const ink100 = Color(0xFFE4E8EF);
  static const ink50 = Color(0xFFF2F4F8);

  static const emerald700 = Color(0xFF08543C);
  static const emerald600 = Color(0xFF0A6046);
  static const emerald500 = Color(0xFF0B6E4F);
  static const emerald100 = Color(0xFFCDE9DC);

  static const brass900 = Color(0xFF3D2F0F);
  static const brass800 = Color(0xFF5C4419);
  static const brass700 = Color(0xFF7A5F23);
  static const brass600 = Color(0xFF9A7629);
  static const brass500 = Color(0xFFB98B34);
  static const brass400 = Color(0xFFCBA35C);
  static const brass300 = Color(0xFFDCBE8A);
  static const brass200 = Color(0xFFEAD5AC);
  static const brass100 = Color(0xFFF3E4C2);
  static const brass50 = Color(0xFFFAF3E3);

  static const rust600 = Color(0xFF7A2831);
  static const rust500 = Color(0xFF8C2F39);
  static const rust100 = Color(0xFFEFCFCD);

  static const paper = Color(0xFFFAFAF8);
  static const paperSoft = Color(0xFFF3F2ED);
  static const paperLine = Color(0xFFE5E2D9);

  // Compatibility names used throughout the existing Flutter UI.
  static const primary = brass500;
  static const primaryLight = brass300;
  static const primaryDark = brass700;
  static const background = paper;
  static const surface = Colors.white;
  static const surfaceLight = paperSoft;
  static const backgroundLight = paper;
  static const surfaceWhite = Colors.white;
  static const surfaceGray = paperSoft;
  static const textPrimary = ink900;
  static const textSecondary = ink500;
  static const textPrimaryLight = ink900;
  static const textSecondaryLight = ink500;
  static const textHint = ink300;
  static const textOnPrimary = Colors.white;
  static const error = rust500;
  static const success = emerald500;
  static const warning = brass500;
  static const info = ink500;

  static const primaryGradient = LinearGradient(
    colors: [brass400, brass600],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const surfaceGradient = LinearGradient(
    colors: [ink800, ink900],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
