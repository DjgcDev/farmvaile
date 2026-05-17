import 'package:flutter/material.dart';

class FarmTheme {
  // Color Palette
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFF4CAF50);
  static const Color softGreen = Color(0xFF81C784);
  static const Color paleGreen = Color(0xFFE8F5E9);
  static const Color accentAmber = Color(0xFFFFA000);
  static const Color accentAmberLight = Color(0xFFFFD54F);
  static const Color soilBrown = Color(0xFF5D4037);
  static const Color skyBlue = Color(0xFF0288D1);
  static const Color textDark = Color(0xFF1B2A1B);
  static const Color textMedium = Color(0xFF4A5E4A);
  static const Color textLight = Color(0xFF7E9B7E);
  static const Color cardWhite = Color(0xFFFAFCFA);
  static const Color backgroundGrey = Color(0xFFF1F6F1);
  static const Color errorRed = Color(0xFFD32F2F);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          secondary: lightGreen,
          tertiary: accentAmber,
          surface: cardWhite,
        ),
        scaffoldBackgroundColor: backgroundGrey,
        fontFamily: 'Georgia',
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        cardTheme: CardThemeData(
          color: cardWhite,
          elevation: 2,
          shadowColor: const Color.fromRGBO(46, 125, 50, 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: paleGreen,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: softGreen, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color.fromRGBO(129, 199, 132, 0.5), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryGreen, width: 2),
          ),
          hintStyle: const TextStyle(color: textLight),
          labelStyle: const TextStyle(color: textMedium),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: primaryGreen,
          unselectedItemColor: textLight,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          elevation: 12,
        ),
        chipTheme: ChipThemeData(
          backgroundColor: paleGreen,
          selectedColor: lightGreen,
          labelStyle: const TextStyle(fontSize: 12, color: textDark),
          side: const BorderSide(color: softGreen),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        dividerTheme: const DividerThemeData(
          color: Color.fromRGBO(129, 199, 132, 0.3),
          thickness: 1,
        ),
      );
}
