import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF3A7FD5),
    scaffoldBackgroundColor: const Color(0xFFF4F8FC),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black87),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF3A7FD5),
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
      elevation: 0,
    ),
    iconTheme: IconThemeData(color: Colors.black54),
    cardColor: Colors.white,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF2266B6),
    scaffoldBackgroundColor: const Color(0xFF141B25),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2266B6),
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
      elevation: 0,
    ),
    iconTheme: IconThemeData(color: Colors.white70),
    cardColor: Color(0xFF222C3A),
  );
}
