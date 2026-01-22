import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Mountain Theme Colors (Golden/Orange Palette)
  static const Color mountainGold = Color(0xFFFFD700);
  static const Color mountainOrange = Color(0xFFFF8C00);
  static const Color mountainDarkBlue = Color(0xFF0A192F); // Deep night sky
  static const Color mountainLightBlue = Color(0xFFE0F7FA); // Icy peak

  // Light Theme (Daylight Mountain)
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: mountainOrange,
    scaffoldBackgroundColor: Colors.transparent, // For background image
    colorScheme: const ColorScheme.light(
      primary: mountainOrange,
      secondary: mountainGold,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      bodyLarge: GoogleFonts.inter(fontSize: 16, color: Colors.black87),
      bodyMedium: GoogleFonts.inter(fontSize: 14, color: Colors.black54),
    ),
    iconTheme: const IconThemeData(color: mountainOrange, size: 24),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      iconTheme: const IconThemeData(color: mountainOrange),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: mountainOrange,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withValues(alpha: 0.9),
    ),
  );

  // Dark Theme (Night Mountain)
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: mountainGold,
    scaffoldBackgroundColor: Colors.transparent, // For background image
    colorScheme: const ColorScheme.dark(
      primary: mountainGold,
      secondary: mountainOrange,
      surface: mountainDarkBlue,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
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
      backgroundColor: Colors.black.withValues(alpha: 0.8),
      selectedItemColor: mountainGold,
      unselectedItemColor: Colors.white38,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: mountainDarkBlue.withValues(alpha: 0.8),
    ),
  );
}
