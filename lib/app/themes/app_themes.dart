import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AppThemes {
  // Modern color palette inspired by skinior.com
  static const Color primaryColor = Color(0xFF000000);
  static const Color secondaryColor = Color(0xFF1A1A1A);
  static const Color accentColor = Color(0xFF6366F1);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  // Light Theme - Modern & Minimalist
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      surface: surfaceColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
    ),

    // Modern app bar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primaryColor,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black12,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: primaryColor,
        letterSpacing: -0.5,
      ),
    ),

    // Modern cards with subtle shadows
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(0),
    ),

    // Modern elevated buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),

    // Modern text buttons
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
      ),
    ),

    // Modern input decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(color: textSecondary, fontSize: 16),
    ),

    // Typography
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: textPrimary,
        letterSpacing: -1,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.3,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: -0.2,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: -0.1,
      ),
    ),

    // Background color
    scaffoldBackgroundColor: backgroundColor,
  );

  // Dark Theme - Modern & Minimalist
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      secondary: accentColor,
      surface: Color(0xFF1A1A1A),
      onPrimary: primaryColor,
      onSecondary: Colors.white,
      onSurface: Colors.white,
    ),

    // Modern app bar (dark)
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A1A1A),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 1,
      shadowColor: Colors.white12,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
    ),

    // Modern cards with subtle shadows (dark)
    cardTheme: CardThemeData(
      color: const Color(0xFF1A1A1A),
      elevation: 0,
      shadowColor: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(0),
    ),

    // Modern elevated buttons (dark)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),

    // Modern text buttons (dark)
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.w500,
          letterSpacing: -0.2,
        ),
      ),
    ),

    // Modern input decoration (dark)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 16),
    ),

    // Typography (dark)
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: Colors.white,
        letterSpacing: -1,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: -0.3,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white,
        letterSpacing: -0.2,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xFF9CA3AF),
        letterSpacing: -0.1,
      ),
    ),

    // Background color (dark)
    scaffoldBackgroundColor: const Color(0xFF0A0A0A),
  );
}
