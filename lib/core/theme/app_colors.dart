import 'package:flutter/material.dart';

class AppColors {
  // LIGHT THEME
  static const Color lightPrimary = Color(0xFF4FACFE);
  static const Color lightSecondary = Color(0xFF00F2FE);
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // DARK THEME (diperbaiki untuk kontras lebih baik)
  static const Color darkPrimary = Color(0xFF4FACFE);  // Sama dengan light agar brand konsisten
  static const Color darkSecondary = Color(0xFF00F2FE);
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);  // Lebih terang untuk readability
  static const Color darkBorder = Color(0xFF334155);

  // GRADIENTS
  static const LinearGradient lightGradient = LinearGradient(
    colors: [lightPrimary, lightSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkPrimary, darkSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // UTILITY: Get current theme colors based on brightness
  static Color getPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkPrimary
        : lightPrimary;
  }
  
  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackground
        : lightBackground;
  }
  
  static Color getSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSurface
        : lightSurface;
  }
  
  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : lightTextPrimary;
  }
  
  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }
  
  static Color getBorder(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBorder
        : lightBorder;
  }
}
