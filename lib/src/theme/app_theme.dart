import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppTheme {
  final ThemeData light;
  final ThemeData dark;
  const AppTheme({required this.light, required this.dark});
}

final appThemeProvider = Provider<AppTheme>((ref) {
  // Modern color scheme with purple/blue gradient
  final colorSchemeLight = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6366F1), // Indigo
    brightness: Brightness.light,
  ).copyWith(
    primary: const Color(0xFF6366F1),
    secondary: const Color(0xFF8B5CF6),
    tertiary: const Color(0xFF06B6D4),
    surface: const Color(0xFFFAFAFA),
    surfaceContainerHighest: const Color(0xFFF3F4F6),
  );

  final colorSchemeDark = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6366F1),
    brightness: Brightness.dark,
  ).copyWith(
    primary: const Color(0xFF818CF8),
    secondary: const Color(0xFFA78BFA),
    tertiary: const Color(0xFF22D3EE),
    surface: const Color(0xFF0F0F0F),
    surfaceContainerHighest: const Color(0xFF1F1F1F),
  );

  return AppTheme(
    light: ThemeData(
      useMaterial3: true,
      colorScheme: colorSchemeLight,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: colorSchemeLight.surfaceContainerHighest,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: colorSchemeLight.surface,
      ),
    ),
    dark: ThemeData(
      useMaterial3: true,
      colorScheme: colorSchemeDark,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: colorSchemeDark.surfaceContainerHighest,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: colorSchemeDark.surface,
      ),
    ),
  );
});


