
import 'package:flutter/material.dart';

class AppColors {
  static const Color orangePrimary = Color(0xFFFF9800); // Main Orange (e.g., Material Orange 500)
  static const Color orangeDark = Color(0xFFF57C00);   // Darker Orange (e.g., Material Orange 700)
  static const Color orangeLight = Color(0xFFFFE0B2);  // Lighter Orange (e.g., Material Orange 100)
  static const Color appBlack = Color(0xFF212121);    // A common dark grey/black
  static const Color appWhite = Colors.white;
  static const Color textBlack = Color(0xFF000000);   // Pure black for text if needed
  static const Color textWhite = Colors.white;

  // Gradient for the first page background and other orange gradient elements
  static const Gradient orangeGradient = LinearGradient(
    colors: [orangeDark, orangePrimary], // Example: Dark to Primary
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradient for category pages (light orange)
  static const Gradient lightOrangeGradient = LinearGradient(
    colors: [orangePrimary, orangeLight], // Example: Primary to Light
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Helper to create a MaterialColor swatch from a single color
  // This is useful if you want to use your custom orange as a primarySwatch in ThemeData
  static MaterialColor getMaterialColor(Color color) {
    final int red = color.red;
    final int green = color.green;
    final int blue = color.blue;
    final Map<int, Color> shades = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6), // This is your primary shade
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };
    return MaterialColor(color.value, shades);
  }

  // You can then define your material color swatch
  static final MaterialColor orangeMaterial = getMaterialColor(orangePrimary);
}
