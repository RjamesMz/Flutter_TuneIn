import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// ─── TuneIn App Theme ─────────────────────────────────────────────────────────
ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: kPrimary,
      onPrimary: kOnPrimary,
      primaryContainer: kPrimaryContainer,
      onPrimaryContainer: Color(0xFF560023),
      secondary: kSecondary,
      onSecondary: kOnSecondary,
      secondaryContainer: kSecondaryContainer,
      onSecondaryContainer: Color(0xFF7A2C3F),
      tertiary: kTertiary,
      onTertiary: Color(0xFFFFEFEE),
      tertiaryContainer: kTertiaryContainer,
      onTertiaryContainer: Color(0xFF5F2A2C),
      error: kError,
      onError: Color(0xFFFFEFEE),
      errorContainer: Color(0xFFFB5151),
      onErrorContainer: Color(0xFF570008),
      surface: kSurface,
      onSurface: kOnSurface,
      surfaceContainerHighest: kSurfaceContainerHighest,
      onSurfaceVariant: kOnSurfaceVariant,
      outline: kOutline,
      outlineVariant: kOutlineVariant,
      inverseSurface: kInverseSurface,
      onInverseSurface: kInverseOnSurface,
      inversePrimary: kInversePrimary,
    ),
    scaffoldBackgroundColor: kBackground,

    // ── Typography ──────────────────────────────────────────────────────────
    textTheme: TextTheme(
      displayLarge:  GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: kOnSurface),
      displayMedium: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: kOnSurface),
      displaySmall:  GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: kOnSurface),
      headlineLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: kOnSurface),
      headlineMedium:GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: kOnSurface),
      headlineSmall: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: kOnSurface),
      titleLarge:    GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: kOnSurface),
      titleMedium:   GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: kOnSurface),
      titleSmall:    GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, color: kOnSurface),
      bodyLarge:     GoogleFonts.beVietnamPro(fontWeight: FontWeight.w400, color: kOnSurface),
      bodyMedium:    GoogleFonts.beVietnamPro(fontWeight: FontWeight.w400, color: kOnSurface),
      bodySmall:     GoogleFonts.beVietnamPro(fontWeight: FontWeight.w300, color: kOnSurfaceVariant),
      labelLarge:    GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, color: kOnSurface),
      labelMedium:   GoogleFonts.beVietnamPro(fontWeight: FontWeight.w500, color: kOnSurface),
      labelSmall:    GoogleFonts.beVietnamPro(fontWeight: FontWeight.w500, color: kOnSurfaceVariant),
    ),

    // ── AppBar ───────────────────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: kSurface.withOpacity(0.85),
      elevation: 0,
      scrolledUnderElevation: 1,
      centerTitle: true,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: kPrimary,
      ),
      iconTheme: const IconThemeData(color: kPrimary),
    ),

    // ── BottomNavigationBar ───────────────────────────────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: kPrimary,
      unselectedItemColor: kOnSurfaceVariant,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // ── InputDecoration ───────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kSurfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
  );
}
