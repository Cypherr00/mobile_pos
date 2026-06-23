// core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary brand identity (Emerald Teal)
  static const Color primary = Color(0xFF0F766E); // Main accent (deep teal)
  static const Color primaryLight = Color(0xFFE2F0EC); // Background tint (light teal)
  static const Color primaryDark = Color(0xFF0D9488); // Secondary teal / hover accent

  // Neutral backgrounds and cards
  static const Color background = Color(0xFFF8FAFC); // Main light scaffold background
  static const Color surface = Colors.white; // Standard card background
  static const Color darkBackground = Color(0xFF0F172A); // Deep slate background (receipt screen)
  static const Color darkSurface = Color(0xFF1E293B); // Deep slate cards / header backgrounds

  // Typography color scales
  static const Color textDark = Color(0xFF1E293B); // Main headlines / body text
  static const Color textMuted = Color(0xFF64748B); // Secondary / subtitles
  static const Color textLight = Color(0xFF94A3B8); // Inactive tabs / labels / borders
  static const Color border = Color(0xFFE2E8F0); // Subtle card borders / lines
  
  // Status and utility accents
  static const Color success = Color(0xFF059669); // Validated inputs / success checkmarks
  static const Color successLight = Color(0xFFD1FAE5); // Light green alerts / tags background
  static const Color danger = Color(0xFFEF4444); // Error buttons / trash actions
  static const Color dangerLight = Color(0xFFFEE2E2); // Light red tags background
  static const Color accent = Color(0xFF7C3AED); // Accent purple (e.g. menu tags)
}
