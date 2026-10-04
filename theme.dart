import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF123B66);
  static const secondary = Color(0xFF2F80ED);
  static const background = Color(0xFFF5F7FA);
  static const success = Color(0xFF27AE60);
  static const warning = Color(0xFFF2C94C);
  static const error = Color(0xFFEB5757);
  static const text = Color(0xFF17202A);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      );
}
