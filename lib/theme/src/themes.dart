import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui_kit/src/utils/colors.dart';

/// This class manages dark and light theme data.
class Themes {
  /// Dark theme data, with specifications for colors, text fonts,
  /// schemes, themes and all kinds of properties for widgets.
  static final darkTheme = ThemeData(
    canvasColor: Colors.transparent,
    primaryColor: ColorsPalette.primaryBlue,
    primaryColorLight: ColorsPalette.primaryBlue,
    primaryColorDark: Colors.white,
    colorScheme: const ColorScheme.dark(
      primary: ColorsPalette.primaryBlue,
      background: ColorsPalette.black,
    ),
    scaffoldBackgroundColor: Colors.black,
    cardColor: ColorsPalette.darkBlack,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ColorsPalette.black,
        enableFeedback: true,
        selectedItemColor: ColorsPalette.primaryBlue),
    shadowColor: Colors.white.withOpacity(0.1),
    fontFamily: "OpenSans",
    dividerColor: ColorsPalette.lightGrey.withOpacity(0.2),
    iconTheme: const IconThemeData(color: ColorsPalette.primaryGrey),
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light, // For Android (light icons)
        statusBarBrightness: Brightness.dark, // For iOS (light icons)
      ),
      color: ColorsPalette.black,
      iconTheme: IconThemeData(color: ColorsPalette.primaryGrey),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 40,
          color: ColorsPalette.primaryBlue),
      displayMedium: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 24,
        color: ColorsPalette.primaryGrey,
      ),
      displaySmall: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 24,
        color: ColorsPalette.primaryBlue,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 20,
        color: ColorsPalette.primaryGrey,
      ),
      headlineSmall: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: ColorsPalette.primaryBlue,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 18,
        color: ColorsPalette.primaryGrey,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: ColorsPalette.primaryGrey,
      ),
      titleSmall: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: ColorsPalette.primaryBlue,
      ),
      bodyLarge: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12,
        color: ColorsPalette.primaryGrey,
      ),
      bodyMedium: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: ColorsPalette.primaryBlue,
      ),
      bodySmall: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 12.0,
        color: ColorsPalette.lightBlack,
      ),
    ),
  );

  /// Light theme data, with specifications for colors, text fonts,
  /// schemes, themes and all kinds of properties for widgets.
  static final lightTheme = ThemeData(
      canvasColor: Colors.transparent,
      primaryColor: ColorsPalette.primaryBlue,
      primaryColorLight: ColorsPalette.primaryBlue,
      primaryColorDark: Colors.black,
      colorScheme: const ColorScheme.light(
        primary: ColorsPalette.primaryBlue,
        background: Colors.white,
      ),
      fontFamily: "OpenSans",
      scaffoldBackgroundColor: ColorsPalette.backgroundGrey,
      cardColor: ColorsPalette.backgroundGrey,
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          enableFeedback: true,
          selectedItemColor: ColorsPalette.primaryBlue),
      shadowColor: Colors.black.withOpacity(0.4),
      dividerColor: ColorsPalette.lightGrey,
      iconTheme: const IconThemeData(color: ColorsPalette.primaryGrey),
      appBarTheme: const AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
          statusBarBrightness: Brightness.light, // For iOS (dark icons)
        ),
        color: ColorsPalette.backgroundGrey,
        iconTheme: IconThemeData(color: ColorsPalette.primaryGrey),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 40,
            color: ColorsPalette.primaryBlue),
        displayMedium: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 24,
          color: ColorsPalette.primaryGrey,
        ),
        displaySmall: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 24,
          color: ColorsPalette.primaryBlue,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 20,
          color: ColorsPalette.primaryGrey,
        ),
        headlineSmall: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 20,
          color: ColorsPalette.primaryBlue,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 18,
          color: ColorsPalette.primaryGrey,
        ),
        titleMedium: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: ColorsPalette.primaryGrey,
        ),
        titleSmall: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: ColorsPalette.primaryBlue,
        ),
        bodyLarge: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12,
          color: ColorsPalette.primaryGrey,
        ),
        bodyMedium: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: ColorsPalette.primaryBlue,
        ),
        bodySmall: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 12.0,
          color: ColorsPalette.lightBlack,
        ),
      ));
}
