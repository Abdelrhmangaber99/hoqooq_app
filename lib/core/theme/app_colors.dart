import 'package:flutter/material.dart';

/// Shared Hoqooq palette.
///
/// These values are the desktop web app's Tailwind theme, read straight out of
/// the built stylesheet (`assets/index-*.css` in the Electron renderer) rather
/// than eyeballed from a screenshot, so the two clients agree exactly.
///
/// The scale is a warm parchment one — brown ink on cream paper with a brass
/// accent — which is what the reference client renders. An earlier revision of
/// this file carried a blue/navy `ink` scale and a green `emerald`; both were
/// from a different design direction and have been replaced.
class AppColors {
  AppColors._();

  // --- ink: text and dark surfaces -------------------------------------
  static const ink900 = Color(0xFF1E160A);
  static const ink800 = Color(0xFF2B2010);
  // Not present in the desktop stylesheet; interpolated between 600 and 800 so
  // the ladder stays monotonic for the existing call sites.
  static const ink700 = Color(0xFF392C18);
  static const ink600 = Color(0xFF4A3A22);
  static const ink500 = Color(0xFF5E4D34);
  static const ink400 = Color(0xFF7A6A52);
  static const ink300 = Color(0xFFA3947C);
  static const ink200 = Color(0xFFCFC5B3);
  static const ink100 = Color(0xFFEAE4D8);
  static const ink50 = Color(0xFFF5F1E9);

  // --- brand: the explicit marketing tokens ----------------------------
  static const brandBrown = Color(0xFF2B2010);
  static const brandGold = Color(0xFFB98B33);
  static const brandGoldLight = Color(0xFFD9B45E);
  static const brandBorder = Color(0xFFE3DDCC);
  static const brandCream = Color(0xFFF6F0E2);
  static const brandCreamLight = Color(0xFFFBFAF6);
  /// The muted gold used for the sign-in subtitle and similar secondary copy.
  static const brandTagline = Color(0xFF8F6618);

  // --- paper: page and surface grounds ---------------------------------
  static const paper = Color(0xFFFBFAF6);
  static const paperSoft = Color(0xFFF6F0E2);
  static const paperLine = Color(0xFFE3DDCC);

  // --- brass: the accent ladder ----------------------------------------
  static const brass900 = Color(0xFF3D2F0F);
  static const brass800 = Color(0xFF5C4418);
  static const brass700 = Color(0xFF8F6618);
  static const brass600 = Color(0xFFA47A26);
  static const brass500 = Color(0xFFB98B33);
  static const brass400 = Color(0xFFD9B45E);
  static const brass300 = Color(0xFFE5CB8E);
  static const brass200 = Color(0xFFEFDDB5);
  static const brass100 = Color(0xFFF6ECD4);
  static const brass50 = Color(0xFFFBF6EA);

  // --- status ----------------------------------------------------------
  // The desktop's "emerald" is a moss/olive green, not the teal-leaning green
  // this file used to carry. The rust ladder already matched upstream.
  static const emerald700 = Color(0xFF4E5A1C);
  static const emerald600 = Color(0xFF5F6C25);
  static const emerald500 = Color(0xFF727F30);
  static const emerald100 = Color(0xFFEAECD2);

  static const rust600 = Color(0xFF7A2831);
  static const rust500 = Color(0xFF8C2F39);
  static const rust100 = Color(0xFFEFCFCD);

  // --- vendor identity (Ethereal Software Solutions) --------------------
  // Fixed brand colours, deliberately outside the parchment scale: the
  // "Powered by" credit keeps its own navy and teal on any background.
  static const etherealNavy = Color(0xFF0E1F3D);
  static const etherealTeal = Color(0xFF13A08F);

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
