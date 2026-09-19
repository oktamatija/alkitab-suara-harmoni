import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';

class AppTheme {
  // Warna Utama Dark Worship
  static const Color darkBg = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceElevated = Color(0xFF283548);
  static const Color goldAccent = Color(0xFFF59E0B);
  static const Color goldDeep = Color(0xFFD97706);
  static const Color skyAccent = Color(0xFF38BDF8);

  // Warna Sepia Paper
  static const Color sepiaBg = Color(0xFFFBF8F1);
  static const Color sepiaSurface = Color(0xFFEFE9DC);
  static const Color sepiaText = Color(0xFF291E14);

  // Warna Clean White
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF0F172A);

  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.darkWorship:
        return _buildDarkTheme();
      case AppThemeMode.warmSepia:
        return _buildSepiaTheme();
      case AppThemeMode.cleanWhite:
        return _buildLightTheme();
    }
  }

  static ThemeData _buildDarkTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: goldAccent,
        secondary: skyAccent,
        surface: darkSurface,
        onPrimary: Color(0xFF000000),
        onSurface: Color(0xFFF8FAFC),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155), width: 0.8),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF0F172A),
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).copyWith(
        bodyLarge: GoogleFonts.lora(color: const Color(0xFFF8FAFC), height: 1.7),
        bodyMedium: GoogleFonts.lora(color: const Color(0xFFE2E8F0), height: 1.6),
      ),
    );
  }

  static ThemeData _buildSepiaTheme() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: sepiaBg,
      colorScheme: const ColorScheme.light(
        primary: goldDeep,
        secondary: Color(0xFFB45309),
        surface: sepiaSurface,
        onSurface: sepiaText,
      ),
      cardTheme: CardThemeData(
        color: sepiaSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFDDD3BE), width: 0.8),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: sepiaBg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: sepiaText,
        ),
        iconTheme: const IconThemeData(color: sepiaText),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFFF4EEE0),
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).copyWith(
        bodyLarge: GoogleFonts.lora(color: sepiaText, height: 1.7),
        bodyMedium: GoogleFonts.lora(color: const Color(0xFF3F3223), height: 1.6),
      ),
    );
  }

  static ThemeData _buildLightTheme() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: goldDeep,
        secondary: skyAccent,
        surface: lightSurface,
        onSurface: lightText,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: lightText,
        ),
        iconTheme: const IconThemeData(color: lightText),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).copyWith(
        bodyLarge: GoogleFonts.lora(color: lightText, height: 1.7),
        bodyMedium: GoogleFonts.lora(color: const Color(0xFF334155), height: 1.6),
      ),
    );
  }
}
