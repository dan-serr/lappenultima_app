import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppenultimaTheme {
  static ThemeData light() {
    return FlexThemeData.light(
        scheme: FlexScheme.espresso,
        usedColors: 4,
        surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
        blendLevel: 20,
        appBarOpacity: 0.95,
        subThemesData: const FlexSubThemesData(
          blendOnLevel: 20,
          blendOnColors: false,
          inputDecoratorBorderType: FlexInputBorderType.underline,
          inputDecoratorRadius: 8.0,
          inputDecoratorUnfocusedHasBorder: false,
        ),
        useMaterial3ErrorColors: true,
        visualDensity: FlexColorScheme.comfortablePlatformDensity,
        useMaterial3: true,
        fontFamily: GoogleFonts.roboto().fontFamily);
  }

  static ThemeData dark() {
    return FlexThemeData.dark(
      scheme: FlexScheme.espresso,
      usedColors: 4,
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurfacesVariantDialog,
      blendLevel: 15,
      appBarStyle: FlexAppBarStyle.surface,
      appBarOpacity: 0.90,
      appBarElevation: 1.0,
      swapColors: true,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 30,
        inputDecoratorBorderType: FlexInputBorderType.underline,
        inputDecoratorRadius: 8.0,
        inputDecoratorUnfocusedHasBorder: false,
      ),
      useMaterial3ErrorColors: true,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.roboto().fontFamily,
    );
  }
}
