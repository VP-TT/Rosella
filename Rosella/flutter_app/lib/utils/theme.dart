// theme.dart
import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: const Color(0xFFE75A7C),
  scaffoldBackgroundColor: const Color(0xFFFCECF1),
  colorScheme: ColorScheme.light(
    primary: const Color(0xFFE75A7C),
    secondary: const Color(0xFFFFD6E0),
    background: const Color(0xFFFCECF1),
  ),
  fontFamily: 'Poppins',
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
      color: Color(0xFF333333),
    ),
    displayMedium: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
      color: Color(0xFF333333),
    ),
    bodyLarge: TextStyle(fontSize: 16.0, color: Color(0xFF666666)),
    bodyMedium: TextStyle(fontSize: 14.0, color: Color(0xFF666666)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFE75A7C),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
    ),
  ),
);
