import 'package:afiete/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

abstract class AppTheme {
  static final ColorScheme _lightColorScheme = const ColorScheme.light(
    primary: AppColors.primaryColor,
    secondary: AppColors.secondaryColor,
    surface: AppColors.primaryBackgroundColor,
    primaryContainer: AppColors.primaryFillColor,
    onPrimaryContainer: AppColors.primaryTextColor,
    error: AppColors.errorColor,
    onPrimary: AppColors.whiteColor,
    onSecondary: AppColors.whiteColor,
    onSurface: AppColors.primaryTextColor,
    onError: AppColors.whiteColor,
  );

  static final ColorScheme _darkColorScheme = const ColorScheme.dark(
    primary: AppColors.primaryColor,
    secondary: AppColors.secondaryColor,
    surface: AppColors.darkSecondaryBackgroundColor,
    primaryContainer: AppColors.darkPrimaryFillColor,
    onPrimaryContainer: AppColors.whiteColor,
    error: AppColors.errorColor,
    onPrimary: AppColors.whiteColor,
    onSecondary: AppColors.whiteColor,
    onSurface: AppColors.darkPrimaryTextColor,
    onError: AppColors.whiteColor,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      fontFamily: 'cairo',
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      scaffoldBackgroundColor: AppColors.primaryBackgroundColor,
      cardColor: AppColors.whiteColor,
      dividerColor: AppColors.primaryFillColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryBackgroundColor,
        foregroundColor: AppColors.primaryTextColor,
        elevation: 0,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.primaryColor,
        contentTextStyle: TextStyle(color: AppColors.whiteColor),
        behavior: SnackBarBehavior.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.whiteColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.unselectedFieldColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.unselectedFieldColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
            width: 1.4,
          ),
        ),
        hintStyle: const TextStyle(color: AppColors.secondaryTextColor),
        labelStyle: const TextStyle(color: AppColors.primaryTextColor),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.primaryTextColor),
        displayMedium: TextStyle(color: AppColors.primaryTextColor),
        displaySmall: TextStyle(color: AppColors.primaryTextColor),
        headlineLarge: TextStyle(color: AppColors.primaryTextColor),
        headlineMedium: TextStyle(color: AppColors.primaryTextColor),
        headlineSmall: TextStyle(color: AppColors.primaryTextColor),
        titleLarge: TextStyle(color: AppColors.primaryTextColor),
        titleMedium: TextStyle(color: AppColors.primaryTextColor),
        titleSmall: TextStyle(color: AppColors.primaryTextColor),
        bodyLarge: TextStyle(color: AppColors.primaryTextColor),
        bodyMedium: TextStyle(color: AppColors.primaryTextColor),
        bodySmall: TextStyle(color: AppColors.secondaryTextColor),
      ),
      iconTheme: const IconThemeData(color: AppColors.unselectedIconColor),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? _lightColorScheme.primary
              : AppColors.unselectedFieldColor,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.selectedFieldColor
              : AppColors.primaryFillColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightColorScheme.primary,
          foregroundColor: AppColors.whiteColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteColor,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      fontFamily: 'cairo',
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      scaffoldBackgroundColor: AppColors.darkBackgroundColor,
      cardColor: AppColors.darkSecondaryBackgroundColor,
      dividerColor: AppColors.darkDividerColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackgroundColor,
        foregroundColor: AppColors.darkPrimaryTextColor,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryColor,
        contentTextStyle: const TextStyle(color: AppColors.whiteColor),
        behavior: SnackBarBehavior.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSecondaryBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.darkUnselectedFieldColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.darkUnselectedFieldColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
            width: 1.4,
          ),
        ),
        hintStyle: const TextStyle(color: AppColors.darkSecondaryTextColor),
        labelStyle: const TextStyle(color: AppColors.darkPrimaryTextColor),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.darkPrimaryTextColor),
        displayMedium: TextStyle(color: AppColors.darkPrimaryTextColor),
        displaySmall: TextStyle(color: AppColors.darkPrimaryTextColor),
        headlineLarge: TextStyle(color: AppColors.darkPrimaryTextColor),
        headlineMedium: TextStyle(color: AppColors.darkPrimaryTextColor),
        headlineSmall: TextStyle(color: AppColors.darkPrimaryTextColor),
        titleLarge: TextStyle(color: AppColors.darkPrimaryTextColor),
        titleMedium: TextStyle(color: AppColors.darkPrimaryTextColor),
        titleSmall: TextStyle(color: AppColors.darkPrimaryTextColor),
        bodyLarge: TextStyle(color: AppColors.darkPrimaryTextColor),
        bodyMedium: TextStyle(color: AppColors.darkPrimaryTextColor),
        bodySmall: TextStyle(color: AppColors.darkSecondaryTextColor),
      ),
      iconTheme: const IconThemeData(color: AppColors.darkUnselectedIconColor),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primaryColor
              : AppColors.unselectedFieldColor,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.darkSwitchSelectedTrackColor
              : AppColors.darkSwitchTrackColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.whiteColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.whiteColor,
      ),
    );
  }
}
