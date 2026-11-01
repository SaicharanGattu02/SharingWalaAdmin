// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      visualDensity: VisualDensity.adaptivePlatformDensity,

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: const Color(0xff8856F4),
        selectionColor: const Color(0xff8856F4).withOpacity(0.3),
        selectionHandleColor: const Color(0xff8856F4),
      ),

      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Inter',

      inputDecorationTheme: InputDecorationTheme(
        // 🔹 Hint text
        hintStyle: const TextStyle(
          fontSize: 14,
          height: 19.36 / 14,
          color: Color(0xffAFAFAF),
          fontWeight: FontWeight.w400,
        ),

        // 🔹 Filled background
        filled: true,
        fillColor: const Color(0xffFCFAFF),

        // 🔹 Padding (center aligned text)
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),

        // 🔹 Default border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(width: 1, color: Color(0xffD0CBDB)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(width: 1, color: Color(0xffD0CBDB)),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(width: 1, color: Color(0xffD0CBDB)),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(width: 1, color: Color(0xffD0CBDB)),
        ),

        errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
      ),
    );
  }
}
