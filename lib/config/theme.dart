import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aquatic Nebula Theme System (Stitch Project 12748038709308192192)
/// Hybrid Neumorphism & Liquid Glass Aesthetic in Light & Dark Modes
class AppTheme {
  // ── Dark Mode Tokens ("Obsidian & Champagne Gold") ────────────────────────
  static const Color darkSurface = Color(0xFF090604); // Solid Deep Obsidian
  static const Color darkContainer = Color(0xFF1C130B); // Rich Dark Chocolate Container
  static const Color darkContainerHigh = Color(0xFF2A1B10); // Elevated Chocolate Gold
  static const Color darkContainerHighest = Color(0xFF382516);
  static const Color darkSurfaceSapphire = Color(0xFF1C130B);
  static const Color darkAbyss = Color(0xFF090604); // Identical to darkSurface for zero color bands

  static const Color darkPrimary = Color(0xFFF5E8D8); // Warm Champagne Cream
  static const Color darkPrimaryContainer = Color(0xFFE4C17C); // Luxury Champagne Gold
  static const Color darkOnPrimary = Color(0xFF170F07); // Deep Espresso Text
  static const Color darkSecondary = Color(0xFFE5D2BA); // Champagne Vanilla
  static const Color darkSecondaryContainer = Color(0xFF4A311A);
  static const Color darkOnSurface = Color(0xFFFAF3EA); // Pure Warm Cream
  static const Color darkOnSurfaceVariant = Color(0xFFD4C4B5); // Muted Champagne Sand
  static const Color darkOutline = Color(0xFF947C68);
  static const Color darkOutlineVariant = Color(0xFF4D3A2B);

  static const Color aquaGlow = Color(0xFFF7E5C8); // Champagne Gold Glow
  static const Color accentGold = Color(0xFFE4C17C);

  // ── Dark Aquatic Blue & Soft Beige Tokens ──────────────────────────────
  static const Color darkAquaticBg = Color(0xFF06283A); // Dark Aquatic Blue Surface
  static const Color darkAquaticBorder = Color(0xFF0B5675); // Dark Aquatic Blue Border
  static const Color softBeige = Color(0xFFD9C8A3); // Soft Beige Text
  static const Color goldenBorder = Color(0xFFE4C17C); // Golden Accent Border
  static const Color royalSapphire = Color(0xFF1769D5); // Royal Blue Sapphire Accent

  // ── Olive Accents (Verification, Success, Events & Compatibility) ─────────
  static const Color oliveGreen = Color(0xFF7C9A3A);
  static const Color deepOlive = Color(0xFF556B2F);
  static const Color darkOlive = Color(0xFF8FAE45);

  // ── Light Mode Tokens ("Mist Aqua & Terra Glass") ─────────────────────────
  static const Color lightSurface = Color(0xFFF3FBFA); // Mist Aqua Light
  static const Color lightContainer = Color(0xFFFFFFFF);
  static const Color lightContainerHigh = Color(0xFFE6F5F3);
  static const Color lightContainerHighest = Color(0xFFD5ECE9);

  static const Color lightPrimary = Color(0xFF006A66); // Deep Aqua
  static const Color lightPrimaryContainer = Color(0xFF18D8D0);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightSecondary = Color(0xFF1769D5); // Sapphire Blue
  static const Color lightSecondaryContainer = Color(0xFFDAE4FF);
  static const Color lightOnSurface = Color(0xFF09233F); // Deep Primary Text
  static const Color lightOnSurfaceVariant = Color(0xFF557086); // Secondary Text
  static const Color lightOutline = Color(0xFF9BB2C2);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient oceanFlowGradient = LinearGradient(
    colors: [
      Color(0xFFF5E8D8),
      Color(0xFFE4C17C),
      Color(0xFFB88C43),
      Color(0xFF4A311A),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient natureConnectionGradient = LinearGradient(
    colors: [Color(0xFFE4C17C), Color(0xFF7C9A3A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientDark = LinearGradient(
    colors: [Color(0xFFF5E8D8), Color(0xFFE4C17C), Color(0xFFB88C43)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradientLight = LinearGradient(
    colors: [Color(0xFF18D8D0), Color(0xFF1769D5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient primaryGradient(bool isDark) =>
      isDark ? primaryGradientDark : primaryGradientLight;

  // ── Neumorphic Dual Shadows ──────────────────────────────────────────────
  static List<BoxShadow> neumorphicDarkShadows = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.85),
      blurRadius: 16,
      offset: const Offset(4, 6),
    ),
    BoxShadow(
      color: const Color(0xFFE4C17C).withValues(alpha: 0.07),
      blurRadius: 8,
      offset: const Offset(-2, -2),
    ),
  ];

  static List<BoxShadow> neumorphicLightShadows = [
    BoxShadow(
      color: const Color(0xFFB0C4C2).withValues(alpha: 0.45),
      blurRadius: 10,
      offset: const Offset(4, 4),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.95),
      blurRadius: 8,
      offset: const Offset(-3, -3),
    ),
  ];

  static List<BoxShadow> neumorphicShadows(bool isDark) =>
      isDark ? neumorphicDarkShadows : neumorphicLightShadows;

  // ── Liquid Glass Decor ───────────────────────────────────────────────────
  static Border glassBorderDark = Border.all(
    color: const Color(0xFFE4C17C).withValues(alpha: 0.28),
    width: 1.0,
  );

  static Border glassBorderLight = Border.all(
    color: const Color(0xFF18D8D0).withValues(alpha: 0.35),
    width: 1.0,
  );

  static BoxDecoration liquidGlassDecoration({
    required bool isDark,
    double radius = 24,
  }) {
    return BoxDecoration(
      color: isDark
          ? const Color(0xFF1C130B).withValues(alpha: 0.85)
          : Colors.white.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular(radius),
      border: isDark ? glassBorderDark : glassBorderLight,
      boxShadow: neumorphicShadows(isDark),
    );
  }

  // ── Legacy Aliases for backward compatibility ────────────────────────────
  static const Color orange = darkPrimary;
  static const Color orangeLight = darkPrimaryContainer;
  static const Color orangeDark = darkSecondaryContainer;
  static const Color deepBlack = darkSurface;
  static const Color darkCard = darkContainer;
  static const Color pureWhite = lightSurface;
  static const Color lightCard = lightContainer;

  static const Color paletteCream = darkOnSurface;
  static const Color paletteViolet = darkSecondary;
  static const Color paletteCharcoal = darkSurface;
  static const Color mountainGold = accentGold;
  static const Color mountainOrange = darkPrimary;
  static const Color mountainDarkBlue = darkContainer;
  static const Color mountainLightBlue = lightContainer;

  static List<BoxShadow> clayShadowSent = neumorphicDarkShadows;
  static List<BoxShadow> clayShadowRecvDark = neumorphicDarkShadows;
  static List<BoxShadow> clayShadowRecvLight = neumorphicLightShadows;

  // ── Light Theme ("Mist Aqua & Terra Glass") ──────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: lightPrimary,
    scaffoldBackgroundColor: lightSurface,
    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      onPrimary: lightOnPrimary,
      primaryContainer: lightPrimaryContainer,
      onPrimaryContainer: lightOnSurface,
      secondary: lightSecondary,
      onSecondary: Colors.white,
      secondaryContainer: lightSecondaryContainer,
      onSecondaryContainer: lightOnSurface,
      surface: lightSurface,
      onSurface: lightOnSurface,
      onSurfaceVariant: lightOnSurfaceVariant,
      outline: lightOutline,
      surfaceContainer: lightContainer,
      surfaceContainerHigh: lightContainerHigh,
    ),
    textTheme: GoogleFonts.lexendTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: lightOnSurface),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: lightOnSurface),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: lightOnSurface),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: lightOnSurface),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: lightOnSurfaceVariant),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: lightOutline),
      ),
    ),
    iconTheme: const IconThemeData(color: lightPrimary, size: 24),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.lexend(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: lightOnSurface,
      ),
      iconTheme: const IconThemeData(color: lightPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: lightPrimary,
      unselectedItemColor: lightOutline,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFF18D8D0), width: 0.5),
      ),
      color: lightContainer,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: lightOnPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 4,
        shadowColor: const Color(0xFF18D8D0).withValues(alpha: 0.4),
        textStyle: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: lightPrimary,
        side: const BorderSide(color: lightPrimary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: lightOutline.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: lightPrimary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      hintStyle: GoogleFonts.lexend(color: lightOnSurfaceVariant.withValues(alpha: 0.6)),
    ),
    dividerColor: lightOutline.withValues(alpha: 0.2),
    chipTheme: ChipThemeData(
      backgroundColor: lightContainerHigh,
      selectedColor: lightPrimaryContainer,
      labelStyle: GoogleFonts.lexend(fontSize: 13, color: lightOnSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
    ),
  );

  // ── Dark Theme ("Abyss & Sapphire") ──────────────────────────────────────
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: darkPrimary,
    scaffoldBackgroundColor: darkSurface,
    colorScheme: const ColorScheme.dark(
      primary: darkPrimary,
      onPrimary: darkOnPrimary,
      primaryContainer: darkPrimaryContainer,
      onPrimaryContainer: darkOnPrimary,
      secondary: darkSecondary,
      onSecondary: darkSurface,
      secondaryContainer: darkSecondaryContainer,
      onSecondaryContainer: darkOnSurface,
      surface: darkSurface,
      onSurface: darkOnSurface,
      onSurfaceVariant: darkOnSurfaceVariant,
      outline: darkOutline,
      surfaceContainer: darkContainer,
      surfaceContainerHigh: darkContainerHigh,
    ),
    textTheme: GoogleFonts.lexendTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: darkOnSurface),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: darkOnSurface),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: darkOnSurface),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: darkOnSurface),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: darkOnSurfaceVariant),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: darkOutline),
      ),
    ),
    iconTheme: const IconThemeData(color: darkPrimary, size: 24),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.lexend(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkOnSurface,
      ),
      iconTheme: const IconThemeData(color: darkPrimary),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: darkPrimary,
      unselectedItemColor: darkOutline,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFF3F2A1C), width: 1.0),
      ),
      color: darkContainer,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: darkPrimaryContainer,
        foregroundColor: darkOnPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 6,
        shadowColor: aquaGlow.withValues(alpha: 0.4),
        textStyle: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: darkPrimary,
        side: BorderSide(color: darkPrimary.withValues(alpha: 0.6), width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: GoogleFonts.lexend(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A1B12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: darkOutline.withValues(alpha: 0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: darkPrimary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      hintStyle: GoogleFonts.lexend(color: darkOnSurfaceVariant.withValues(alpha: 0.6)),
    ),
    dividerColor: darkOutline.withValues(alpha: 0.2),
    chipTheme: ChipThemeData(
      backgroundColor: darkContainerHigh,
      selectedColor: darkSecondaryContainer,
      labelStyle: GoogleFonts.lexend(fontSize: 13, color: darkOnSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
    ),
  );
}

