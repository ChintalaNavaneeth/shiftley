import 'package:flutter/material.dart';

class ShiftleyTokens {
  // ─── Colors ───────────────────────────────────────────────
  static const Color background    = Color(0xFFF5F5F5);
  static const Color primaryRed    = Color(0xFFFF0000);
  static const Color secondaryCyan = Color(0xFFDFF1F1);
  static const Color utilityGrey   = Color(0xFFBBD5DA);
  static const Color inkBlack      = Color(0xFF000000);
  static const Color paperWhite    = Color(0xFFFFFFFF);
  static const Color mutedText     = Color(0xFF6B6B6B);
  static const Color errorRed      = Color(0xFFCC0000);
  static const Color saveBlue      = Color(0xFF2D5AF7);

  // ─── Spacing ──────────────────────────────────────────────
  static const double spaceXS  =  4.0;
  static const double spaceS   =  8.0;
  static const double spaceM   = 16.0;
  static const double spaceL   = 24.0;
  static const double spaceXL  = 40.0;
  static const double spaceXXL = 64.0;

  // ─── Borders ──────────────────────────────────────────────
  static const double borderWidth     = 2.0;
  static const double borderRadiusVal = 4.0;

  static Border get primaryBorder =>
      Border.all(color: inkBlack, width: borderWidth);

  static Border get focusBorder =>
      Border.all(color: primaryRed, width: borderWidth);

  static Border get thinBorder =>
      Border.all(color: inkBlack, width: 1.0);

  static BorderSide get thinBorderSide =>
      const BorderSide(color: inkBlack, width: 1.0);

  static BorderSide get primaryBorderSide =>
      const BorderSide(color: inkBlack, width: borderWidth);

  static BorderSide get focusBorderSide =>
      const BorderSide(color: primaryRed, width: borderWidth);

  static InputBorder get primaryInputBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusVal),
        borderSide: primaryBorderSide,
      );

  static InputBorder get focusInputBorder => OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadiusVal),
        borderSide: focusBorderSide,
      );

  static InputBorder get underlineInputBorder => const UnderlineInputBorder(
        borderSide: BorderSide(color: inkBlack, width: borderWidth),
      );

  static InputBorder get underlineFocusInputBorder => const UnderlineInputBorder(
        borderSide: BorderSide(color: primaryRed, width: borderWidth),
      );

  // ─── Typography ───────────────────────────────────────────
  // Uses locally bundled fonts declared in pubspec.yaml

  static const TextStyle displayLogo = TextStyle(
    fontFamily: 'Licorice',
    fontSize: 96, // Increased by ~15% from 84
    fontWeight: FontWeight.w700, 
    color: inkBlack,
    height: 1.0,
  );

  static const TextStyle heroLarge = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 40, // Decreased by ~15% from 48
    fontWeight: FontWeight.w900,
    color: inkBlack,
    letterSpacing: -1.0,
    height: 1.1,
  );

  static const TextStyle h1 = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 27, // Decreased by ~15% from 32
    fontWeight: FontWeight.w800,
    color: inkBlack,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 20, // Decreased by ~15% from 24
    fontWeight: FontWeight.w700,
    color: inkBlack,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 15, // Decreased by ~15% from 18
    fontWeight: FontWeight.w600,
    color: inkBlack,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 14, // Decreased by ~15% from 16
    fontWeight: FontWeight.w400,
    color: inkBlack,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 11, // Decreased by ~15% from 13
    fontWeight: FontWeight.w400,
    color: mutedText,
  );

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: 'Figtree',
    fontSize: 14, // Decreased by ~15% from 16
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
}
