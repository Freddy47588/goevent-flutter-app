import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.lightBackground,

    colorScheme: ColorScheme.light(
      primary: AppColors.lightPrimary,
      secondary: AppColors.lightSecondary,
      surface: AppColors.lightSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.lightTextPrimary,
      outline: AppColors.lightBorder,
    ),

    // Text theme configuration
    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      displayMedium: AppTextStyles.h2.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      displaySmall: AppTextStyles.h3.copyWith(
        color: AppColors.lightTextPrimary,
      ),
      bodyLarge: AppTextStyles.body.copyWith(color: AppColors.lightTextPrimary),
      bodyMedium: AppTextStyles.body.copyWith(
        color: AppColors.lightTextSecondary,
      ),
      bodySmall: AppTextStyles.caption.copyWith(
        color: AppColors.lightTextSecondary,
      ),
    ),

    // AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      centerTitle: true,
    ),

    fontFamily: 'Poppins',
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.darkBackground,

    colorScheme: ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.darkSecondary,
      surface: AppColors.darkSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.darkTextPrimary,
      outline: AppColors.darkBorder,
    ),

    // Text theme configuration
    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1.copyWith(color: AppColors.darkTextPrimary),
      displayMedium: AppTextStyles.h2.copyWith(
        color: AppColors.darkTextPrimary,
      ),
      displaySmall: AppTextStyles.h3.copyWith(color: AppColors.darkTextPrimary),
      bodyLarge: AppTextStyles.body.copyWith(color: AppColors.darkTextPrimary),
      bodyMedium: AppTextStyles.body.copyWith(
        color: AppColors.darkTextSecondary,
      ),
      bodySmall: AppTextStyles.caption.copyWith(
        color: AppColors.darkTextSecondary,
      ),
    ),

    // AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    fontFamily: 'Poppins',
  );
}
