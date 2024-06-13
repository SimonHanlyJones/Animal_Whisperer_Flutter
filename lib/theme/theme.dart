import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

const Color headerColour = Color(0xFFB89842);
const Color backgroundColour = Color(0xFFaeab8a);
const Color titleColour = Color.fromRGBO(220, 217, 174, 1);
const Color userBubblesColour = Color(0xFF262930);
const Color botBubblesColour = Color(0xFFd7d2a8);
const Color footerColour = Color(0xFFB89842);
const Color buttonColour1 = Color(0xFFB89842);
const Color buttonColour2 = Color(0xFF262930);
const Color textParchment = Color.fromRGBO(220, 217, 174, 1);
const Color textDark = Color(0xFF602D0D);

class AppTheme {
  static ThemeData get greenTheme {
    return ThemeData(
      useMaterial3: true, // Ensure Material 3 is enabled
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        // header and footer colors
        primary: Color(0xFFB89842),
        onPrimary: Color.fromRGBO(220, 217, 174, 1),
        // user bubble colors
        secondary: Color(0xFF3c341f),
        onSecondary: Color.fromRGBO(220, 217, 174, 1),
        // bot bubble colors
        tertiary: Color(0xFFd7d2a8),
        onTertiary: Color(0xFF262930),
        error: Colors.red,
        onError: Colors.white,
        surface: Color(0xFF3c341f),
        onSurface: Color.fromRGBO(220, 217, 174, 1),
        surfaceContainer: Color.fromARGB(255, 99, 128, 86),
        surfaceContainerHigh: Color.fromARGB(255, 66, 87, 56),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: headerColour, // Set AppBar background color
        titleTextStyle: TextStyle(
          color: Color(0xFF3c341f), // Set AppBar text color
          fontSize: 20, // Set font size for AppBar title
          fontWeight: FontWeight.bold, // Set font weight for AppBar title
        ),
        iconTheme: IconThemeData(
          color: titleColour, // Set color for AppBar icons
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: userBubblesColour,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        hintStyle: const TextStyle(
          color: textParchment,
          fontSize: 16, // Adjust the font size as needed
          height: 1.25,
        ),
      ),
    );
  }
}

class FlexTheme {
  static final Map<String, ThemeData> themes = {
// Theme config for FlexColorScheme version 7.3.x. Make sure you use
// same or higher package version, but still same major version. If you
// use a lower package version, some properties may not be supported.
// In that case remove them after copying this theme to your app.
    'theme': FlexThemeData.light(
      colors: const FlexSchemeColor(
        primary: Color(0xffb89842),
        primaryContainer: Color(0xffd0e4ff),
        secondary: Color(0xff262930),
        secondaryContainer: Color(0xffffdbcf),
        tertiary: Color(0xffd7d2a8),
        tertiaryContainer: Color(0xff95f0ff),
        appBarColor: Color(0xffffdbcf),
        error: Color(0xffb00020),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 40,
      subThemesData: const FlexSubThemesData(
        interactionEffects: false,
        tintedDisabledControls: false,
        blendOnColors: false,
        useTextTheme: true,
        inputDecoratorBorderType: FlexInputBorderType.underline,
        inputDecoratorUnfocusedBorderIsColored: false,
        alignedDropdown: true,
        tooltipRadius: 4,
        tooltipSchemeColor: SchemeColor.inverseSurface,
        tooltipOpacity: 0.9,
        useInputDecoratorThemeInDialogs: true,
        snackBarElevation: 6,
        snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
        navigationBarSelectedLabelSchemeColor: SchemeColor.onSurface,
        navigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
        navigationBarMutedUnselectedLabel: false,
        navigationBarSelectedIconSchemeColor: SchemeColor.onSurface,
        navigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
        navigationBarMutedUnselectedIcon: false,
        navigationBarIndicatorSchemeColor: SchemeColor.secondaryContainer,
        navigationBarIndicatorOpacity: 1.00,
        navigationRailSelectedLabelSchemeColor: SchemeColor.onSurface,
        navigationRailUnselectedLabelSchemeColor: SchemeColor.onSurface,
        navigationRailMutedUnselectedLabel: false,
        navigationRailSelectedIconSchemeColor: SchemeColor.onSurface,
        navigationRailUnselectedIconSchemeColor: SchemeColor.onSurface,
        navigationRailMutedUnselectedIcon: false,
        navigationRailIndicatorSchemeColor: SchemeColor.secondaryContainer,
        navigationRailIndicatorOpacity: 1.00,
        navigationRailBackgroundSchemeColor: SchemeColor.surface,
        navigationRailLabelType: NavigationRailLabelType.none,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      // To use the Playground font, add GoogleFonts package and uncomment
      // fontFamily: GoogleFonts.notoSans().fontFamily,
    ),
    'darkTheme': FlexThemeData.dark(
      colors: const FlexSchemeColor(
        primary: Color(0xffb89842),
        primaryContainer: Color(0xff00325b),
        secondary: Color(0xff262930),
        secondaryContainer: Color(0xff872100),
        tertiary: Color(0xffd7d2a8),
        tertiaryContainer: Color(0xff004e59),
        appBarColor: Color(0xff872100),
        error: Color(0xffcf6679),
      ),
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 25,
      subThemesData: const FlexSubThemesData(
        interactionEffects: false,
        tintedDisabledControls: false,
        useTextTheme: true,
        inputDecoratorBorderType: FlexInputBorderType.underline,
        inputDecoratorUnfocusedBorderIsColored: false,
        alignedDropdown: true,
        tooltipRadius: 4,
        tooltipSchemeColor: SchemeColor.inverseSurface,
        tooltipOpacity: 0.9,
        useInputDecoratorThemeInDialogs: true,
        snackBarElevation: 6,
        snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
        navigationBarSelectedLabelSchemeColor: SchemeColor.onSurface,
        navigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
        navigationBarMutedUnselectedLabel: false,
        navigationBarSelectedIconSchemeColor: SchemeColor.onSurface,
        navigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
        navigationBarMutedUnselectedIcon: false,
        navigationBarIndicatorSchemeColor: SchemeColor.secondaryContainer,
        navigationBarIndicatorOpacity: 1.00,
        navigationRailSelectedLabelSchemeColor: SchemeColor.onSurface,
        navigationRailUnselectedLabelSchemeColor: SchemeColor.onSurface,
        navigationRailMutedUnselectedLabel: false,
        navigationRailSelectedIconSchemeColor: SchemeColor.onSurface,
        navigationRailUnselectedIconSchemeColor: SchemeColor.onSurface,
        navigationRailMutedUnselectedIcon: false,
        navigationRailIndicatorSchemeColor: SchemeColor.secondaryContainer,
        navigationRailIndicatorOpacity: 1.00,
        navigationRailBackgroundSchemeColor: SchemeColor.surface,
        navigationRailLabelType: NavigationRailLabelType.none,
      ),
      keyColors: const FlexKeyColors(
        useSecondary: true,
        useTertiary: true,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      // To use the Playground font, add GoogleFonts package and uncomment
      // fontFamily: GoogleFonts.notoSans().fontFamily,
    ),
// If you do not have a themeMode switch, uncomment this line
// to let the device system mode control the theme mode:
// themeMode: ThemeMode.system,
  };
}
