import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Theme colors from Coolors palette: https://coolors.co/ecd0c1-9586e9-372f37
class AppTheme {
  // Coolors palette: cream, violet, charcoal
  static const Color paletteCream = Color(0xFFECD0C1);   // #ecd0c1 - light surface
  static const Color paletteViolet = Color(0xFF9586E9);  // #9586e9 - primary accent
  static const Color paletteCharcoal = Color(0xFF372F37); // #372f37 - dark surface

  // Aliases used across the app (same values as palette)
  static const Color mountainGold = Color(0xFFB8AEF0);   // lighter violet - secondary
  static const Color mountainOrange = Color(0xFF9586E9);  // violet - primary
  static const Color mountainDarkBlue = Color(0xFF372F37); // charcoal
  static const Color mountainLightBlue = Color(0xFFECD0C1); // cream

  // Light Theme (cream + violet)
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: mountainOrange,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: const ColorScheme.light(
      primary: paletteViolet,
      secondary: paletteCream,
      surface: paletteCream,
      onPrimary: Colors.white,
      onSecondary: Color(0xFF372F37),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF372F37),
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Color(0xFF372F37),
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: Color(0xFF372F37)),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: Color(0xFF372F37)),
    ),
    iconTheme: const IconThemeData(color: paletteViolet, size: 24),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF372F37),
      ),
      iconTheme: const IconThemeData(color: paletteViolet),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: paletteCream,
      selectedItemColor: paletteViolet,
      unselectedItemColor: Color(0xFF372F37),
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: paletteCream.withValues(alpha: 0.95),
    ),
    // Figma-style: rounded buttons and inputs
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: const Color(0xFF372F37).withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: paletteViolet, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
  );

  // Dark Theme (charcoal + violet)
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: mountainGold,
    scaffoldBackgroundColor: Colors.transparent,
    colorScheme: const ColorScheme.dark(
      primary: paletteViolet,
      secondary: mountainGold,
      surface: paletteCharcoal,
      onPrimary: Colors.white,
      onSecondary: paletteCream,
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
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: Colors.white60),
    ),
    iconTheme: const IconThemeData(color: mountainGold, size: 24),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      iconTheme: const IconThemeData(color: mountainGold),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: paletteCharcoal.withValues(alpha: 0.95),
      selectedItemColor: mountainGold,
      unselectedItemColor: Colors.white38,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: paletteCharcoal.withValues(alpha: 0.9),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: mountainGold, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
  );
}
