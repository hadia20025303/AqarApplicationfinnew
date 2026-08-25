import 'package:flutter/material.dart';

class AppTheme {

  static const Color primaryDark = Color(0xFF0F172A);
  static const Color secondaryDark = Color(0xFF020617);
  static const Color goldAccent = Color(0xFFD4AF37);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color fieldBg = Color(0xFF1E293B);


  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: secondaryDark,
      primaryColor: goldAccent,
      

      fontFamily: 'Cairo', 


      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: goldAccent),
        titleTextStyle: TextStyle(
          color: goldAccent,
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),


      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldBg,
        labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: goldAccent, width: 1),
        ),
      ),


      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldAccent,
          foregroundColor: secondaryDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
        ),
      ),


      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: primaryDark,
        selectedItemColor: goldAccent,
        unselectedItemColor: Colors.white38,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
    );
  }
}