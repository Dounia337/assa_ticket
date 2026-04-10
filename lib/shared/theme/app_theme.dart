import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF000B60);
  static const Color primaryContainer = Color(0xFF142283);
  static const Color onPrimary = Colors.white;
  static const Color primaryFixed = Color(0xFFE8EAFF);
  static const Color onPrimaryFixedVariant = Color(0xFF142283);

  static const Color secondary = Color(0xFF6B4EFF);
  static const Color secondaryContainer = Color(0xFFB78EFE);
  static const Color secondaryFixed = Color(0xFFF3EEFF);
  static const Color onSecondaryContainer = Colors.white;

  static const Color tertiary = Color(0xFF7B5EAB);
  static const Color tertiaryContainer = Color(0xFFF0E8FF);
  static const Color onTertiaryContainer = Color(0xFF4A2D8B);

  static const Color success = Color(0xFF1E8A44);
  static const Color successContainer = Color(0xFFD4EDDA);
  static const Color warning = Color(0xFFE65100);
  static const Color warningContainer = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFB00020);
  static const Color errorContainer = Color(0xFFFFDAD6);

  static const Color background = Color(0xFFF9F9FB);
  static const Color onBackground = Color(0xFF1A1C1D);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F4F8);
  static const Color surfaceContainerHigh = Color(0xFFE8E8EE);

  static const Color outline = Color(0xFF767680);
  static const Color outlineVariant = Color(0xFFE0E0E8);
  static const Color onSurfaceVariant = Color(0xFF6E6E8A);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF000B60), Color(0xFF3A0CA3)],
  );

  static const LinearGradient ticketGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF000B60), Color(0xFF1A0050), Color(0xFF3A0CA3)],
  );
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryContainer,
        tertiary: AppColors.tertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        error: AppColors.error,
        errorContainer: AppColors.errorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onBackground,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.onBackground),
        headlineLarge: GoogleFonts.manrope(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onBackground),
        headlineMedium: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onBackground),
        headlineSmall: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.onBackground),
        titleLarge: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.onBackground),
        titleMedium: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onBackground),
        bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 16, color: AppColors.onBackground),
        bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppColors.onBackground),
        bodySmall: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.onSurfaceVariant),
        labelLarge: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.onBackground),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onBackground),
        titleTextStyle: GoogleFonts.manrope(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.onBackground),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.outlineVariant)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.error)),
        hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.onSurfaceVariant, fontSize: 14),
        labelStyle: GoogleFonts.plusJakartaSans(color: AppColors.onSurfaceVariant, fontSize: 14),
        prefixIconColor: AppColors.onSurfaceVariant,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.outlineVariant, width: 0.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: GoogleFonts.plusJakartaSans(color: Colors.white),
        backgroundColor: AppColors.onBackground,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}
