import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static const String displayFont = 'Amiri';
  static const String sansFont = 'IBM Plex Sans Arabic';
  static const String monoFont = 'IBM Plex Mono';

  static TextStyle get h1 => GoogleFonts.amiri(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: AppColors.ink800,
      );

  static TextStyle get h2 => GoogleFonts.amiri(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.ink800,
      );

  static TextStyle get h3 => GoogleFonts.ibmPlexSansArabic(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.ink800,
      );

  static TextStyle get bodyLarge => GoogleFonts.ibmPlexSansArabic(
        fontSize: 15,
        color: AppColors.ink700,
      );

  static TextStyle get bodyMedium => GoogleFonts.ibmPlexSansArabic(
        fontSize: 13,
        color: AppColors.ink700,
      );

  static TextStyle get bodySmall => GoogleFonts.ibmPlexSansArabic(
        fontSize: 11.5,
        color: AppColors.ink400,
      );

  static TextStyle get labelLarge => GoogleFonts.ibmPlexSansArabic(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.ink700,
      );

  static TextStyle get labelMedium => GoogleFonts.ibmPlexSansArabic(
        fontSize: 11.5,
        fontWeight: FontWeight.w500,
        color: AppColors.ink500,
      );

  static TextStyle get mono => GoogleFonts.ibmPlexMono(
        fontSize: 13,
        color: AppColors.ink700,
      );
}
