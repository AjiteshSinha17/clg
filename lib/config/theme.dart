import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Black + Orange (dark) / White + Orange (light) theme
class AppTheme {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color orange = Color(0xFFFF6B00); // primary accent
  static const Color orangeLight = Color(0xFFFF8C3A); // lighter glow
  static const Color orangeDark = Color(0xFFCC5500); // pressed / shadow
  static const Color deepBlack = Color(0xFF0A0A0A); // dark scaffold
  static const Color darkSurface = Color(0xFF1A1A1A); // dark cards
  static const Color darkCard = Color(0xFF222222); // dark bubbles recv
  static const Color pureWhite = Color(0xFFFFFFFF); // light scaffold
  static const Color lightSurface = Color(0xFFF5F5F5); // light cards
  static const Color lightCard = Color(0xFFEFEFEF); // light recv bubbles

  // ── Legacy aliases (kept for backward compat with existing screens) ──────
  static const Color paletteCream = lightSurface;
  static const Color paletteViolet = orange;
  static const Color paletteCharcoal = deepBlack;
  static const Color mountainGold = orangeLight;
  static const Color mountainOrange = orange;
  static const Color mountainDarkBlue = darkSurface;
  static const Color mountainLightBlue = lightSurface;

  // ── Shared decoration helpers ────────────────────────────────────────────
  /// Claymorphism-style box shadow for sent bubbles
  static List<BoxShadow> clayShadowSent = [
    BoxShadow(
      color: orangeDark.withValues(alpha: 0.45),
      blurRadius: 12,
      offset: const Offset(0, 5),
    ),
    BoxShadow(
      color: orangeLight.withValues(alpha: 0.20),
      blurRadius: 4,
      offset: const Offset(0, -2),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.08),
      blurRadius: 2,
      offset: const Offset(-1, -1),
    ),
  ];

  /// Claymorphism-style box shadow for received bubbles (dark)
  static List<BoxShadow> clayShadowRecvDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.50),
      blurRadius: 10,
      offset: const Offset(0, 5),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.04),
      blurRadius: 3,
      offset: const Offset(-1, -1),
    ),
  ];

  /// Claymorphism-style box shadow for received bubbles (light)
  static List<BoxShadow> clayShadowRecvLight = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.80),
      blurRadius: 3,
      offset: const Offset(-1, -1),
    ),
  ];

  // ── Light Theme ──────────────────────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: orange,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: const ColorScheme.light(
      primary: orange,
      secondary: orangeLight,
      surface: lightSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1A1A1A),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: Color(0xFF1A1A1A)),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: Color(0xFF2A2A2A)),
      bodySmall: GoogleFonts.inter(fontSize: 12, color: Color(0xFF555555)),
    ),
    iconTheme: const IconThemeData(color: orange, size: 24),
    appBarTheme: AppBarTheme(
      backgroundColor: pureWhite,
      elevation: 0,
      centerTitle: true,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
      iconTheme: const IconThemeData(color: orange),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: pureWhite,
      selectedItemColor: orange,
      unselectedItemColor: Color(0xFF888888),
      type: BottomNavigationBarType.fixed,
      elevation: 12,
    ),
    cardTheme: CardThemeData(
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: pureWhite,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: orangeDark.withValues(alpha: 0.4),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: orange,
        side: const BorderSide(color: orange, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: orange, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: TextStyle(color: Colors.black.withValues(alpha: 0.35)),
    ),
    dividerColor: Colors.black.withValues(alpha: 0.08),
    chipTheme: ChipThemeData(
      backgroundColor: lightCard,
      selectedColor: orange,
      labelStyle: GoogleFonts.inter(
        fontSize: 13,
        color: const Color(0xFF1A1A1A),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );

  // ── Dark Theme ───────────────────────────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: orange,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: const ColorScheme.dark(
      primary: orange,
      secondary: orangeLight,
      surface: darkSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: Colors.white70),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: Colors.white70),
      bodySmall: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
    ),
    iconTheme: const IconThemeData(color: orange, size: 24),
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      elevation: 0,
      centerTitle: true,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: orange),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: orange,
      unselectedItemColor: Colors.white38,
      type: BottomNavigationBarType.fixed,
      elevation: 12,
    ),
    cardTheme: CardThemeData(
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: darkCard,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: orange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: orangeDark.withValues(alpha: 0.5),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: orange,
        side: const BorderSide(color: orange, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: orange, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
    ),
    dividerColor: Colors.white.withValues(alpha: 0.08),
    chipTheme: ChipThemeData(
      backgroundColor: darkCard,
      selectedColor: orange,
      labelStyle: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
