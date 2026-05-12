import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Electric Blue & Accents
  static const primaryAccent = Color(0xFF0078D4);
  static const secondaryAccent = Color(0xFF2B88D8);
  
  // Surface colors for a refined look
  static const lightSurface = Color(0xFFF9F9F9);
  static const darkSurface = Color(0xFF1A1A1A);

  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryAccent,
      brightness: Brightness.light,
      surface: lightSurface,
      surfaceVariant: Colors.white,
      primary: primaryAccent,
    ),
    textTheme: GoogleFonts.notoSansTextTheme(
      const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -1, color: Color(0xFF202020)),
        displayMedium: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF202020)),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Color(0xFF202020)),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
    ),
    dividerTheme: DividerThemeData(
      thickness: 1,
      color: Colors.black.withOpacity(0.05),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryAccent,
      brightness: Brightness.dark,
      surface: darkSurface,
      surfaceVariant: const Color(0xFF252525),
      primary: primaryAccent,
    ),
    textTheme: GoogleFonts.notoSansTextTheme(
      ThemeData.dark().textTheme.copyWith(
        displayLarge: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -1, color: Colors.white),
        displayMedium: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      color: const Color(0xFF252525),
    ),
    dividerTheme: DividerThemeData(
      thickness: 1,
      color: Colors.white.withOpacity(0.05),
    ),
  );
}
