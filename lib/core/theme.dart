// lib/core/theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ─── Palette ────────────────────────────────────────────
  // Haut contraste obligatoire pour malvoyants
  static const Color _primary = Color(0xFFFFB300); // ambre vif
  static const Color _danger = Color(0xFFE53935); // rouge urgent
  static const Color _attention = Color(0xFFFF6F00); // orange
  static const Color _proche = Color(0xFF43A047); // vert
  static const Color _ok = Color(0xFF1E88E5); // bleu calme
  static const Color _background = Color(0xFF0A0A0A); // noir profond
  static const Color _surface = Color(0xFF1A1A1A); // surface sombre
  static const Color _onSurface = Color(0xFFEEEEEE); // texte clair
  static const Color _onPrimary = Color(0xFF000000); // texte sur ambre

  // ─── Couleurs publiques (utilisées dans les widgets) ────
  static const Color dangerColor = _danger;
  static const Color attentionColor = _attention;
  static const Color procheColor = _proche;
  static const Color okColor = _ok;
  static const Color primaryColor = _primary;
  static const Color bgColor = _background;
  static const Color surfaceColor = _surface;

  // ─── ThemeData principal ────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _background,

    colorScheme: const ColorScheme.dark(
      primary: _primary,
      secondary: _attention,
      surface: _surface,
      error: _danger,
      onPrimary: _onPrimary,
      onSurface: _onSurface,
    ),

    // ─── AppBar ───────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: _background,
      foregroundColor: _primary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: _primary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    ),

    // ─── Texte — grandes polices pour malvoyants ──────────
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        color: _onSurface,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: _onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: _onSurface,
        height: 1.5,
      ),
      bodyMedium: TextStyle(fontSize: 16, color: _onSurface, height: 1.5),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _onPrimary,
        letterSpacing: 0.5,
      ),
    ),

    // ─── Boutons ──────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: _onPrimary,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    ),

    // ─── Inputs ───────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primary, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.white54, fontSize: 16),
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),

    // ─── SnackBar ─────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _surface,
      contentTextStyle: const TextStyle(color: _onSurface, fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),

    // ─── BottomNavigationBar ──────────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _surface,
      selectedItemColor: _primary,
      unselectedItemColor: Colors.white38,
      selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 13),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),

    // ─── Card ─────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: _surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );

  // ─── Helper : couleur selon niveau de danger ────────────
  static Color dangerLevelColor(String level) {
    switch (level) {
      case 'DANGER':
        return _danger;
      case 'ATTENTION':
        return _attention;
      case 'PROCHE':
        return _proche;
      default:
        return _ok;
    }
  }

  // ─── Helper : icône selon niveau de danger ──────────────
  static IconData dangerLevelIcon(String level) {
    switch (level) {
      case 'DANGER':
        return Icons.warning_rounded;
      case 'ATTENTION':
        return Icons.error_outline_rounded;
      case 'PROCHE':
        return Icons.info_outline_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }
}
