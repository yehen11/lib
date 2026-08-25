/*
@Author - AchinthaHarshamal
@Date - 2025/10/05
 */

import 'package:flutter/material.dart';
import 'utils.dart';

class AppScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primaryLightColor, brightness: Brightness.light),
      visualDensity: VisualDensity.standard,
      splashFactory: InkRipple.splashFactory,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w600),
        displayMedium: TextStyle(fontSize: 40, fontWeight: FontWeight.w600),
        headlineLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.4),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.4),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: secondaryLightColor,
        foregroundColor: primaryDarkColor,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: primaryLightColor.withAlpha((0.08 * 255).toInt()),
        hintStyle: TextStyle(color: primaryDarkColor.withAlpha((0.4 * 255).toInt())),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryLightColor, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: secondaryLightColor,
        indicatorColor: primaryLightColor,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      iconTheme: IconThemeData(color: primaryDarkColor),
    );
  }

  static ThemeMode get themeMode => ThemeMode.light;
  
  static ScrollBehavior get scrollBehavior => AppScrollBehavior();
}
