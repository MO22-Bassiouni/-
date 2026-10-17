import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData mk(Brightness b) {
  final cs =
      ColorScheme.fromSeed(seedColor: const Color(0xFF0F8B8D), brightness: b);
  final dark = b == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    colorScheme: cs,
    scaffoldBackgroundColor:
        dark ? const Color(0xFF0C1718) : const Color(0xFFF3F7F6),
    textTheme: GoogleFonts.cairoTextTheme(ThemeData(brightness: b).textTheme),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xFF142526) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: dark ? Colors.white24 : Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: dark ? Colors.white24 : Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0F8B8D), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 1.8),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      errorStyle:
          const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
    ),
  );
}
