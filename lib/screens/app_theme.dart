import 'package:flutter/material.dart';

class AppTheme {
  static const Color _coreAccent = Color(0xFFFFEB00);
  
  // Dark Palette
  static const Color _darkBackground = Color(0xFF000957);
  static const Color _darkSurface = Color(0xFF1a234f);
  static const Color _darkPrimary = Color(0xFF344CB7);
  static const Color _darkSecondary = Color(0xFF577BC1);
  static const Color _darkOnPrimary = Colors.white;
  //static const Color _darkOnSurfaceVariant = Color(0xFFB0C4FF);

  // Light Palette
  static const Color _lightBackground = Color(0xFFF0F4FF);
  static const Color _lightSurface = Colors.white;
  static const Color _lightPrimary = Color(0xFF344CB7);
  static const Color _lightOnPrimary = Colors.white;
  static const Color _lightOnSurface = Color(0xFF000957);
  static const Color _lightOnSurfaceVariant = Color(0xFF5A7BDB);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        onPrimary: _lightOnPrimary,
        surface: _lightSurface,
        onSurface: _lightOnSurface,
        secondary: _coreAccent,
        onSecondary: _lightOnSurface,
        tertiary: _lightOnSurfaceVariant,
      ),
      scaffoldBackgroundColor: _lightBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: _lightOnSurface, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: _lightOnSurface),
      ),
      /* cardTheme: const CardTheme(
        color: _lightSurface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ), */
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _coreAccent,
        foregroundColor: _lightOnSurface,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        onPrimary: _darkOnPrimary,
        surface: _darkSurface,
        onSurface: _darkOnPrimary,
        secondary: _darkSecondary,
        onSecondary: _darkOnPrimary,
        tertiary: _coreAccent,
      ),
      scaffoldBackgroundColor: _darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(color: _darkOnPrimary, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: _darkOnPrimary),
      ),
      /* cardTheme: const CardTheme(
        color: _darkSurface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ), */
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _coreAccent,
        foregroundColor: _darkBackground,
      ),
    );
  }
}
