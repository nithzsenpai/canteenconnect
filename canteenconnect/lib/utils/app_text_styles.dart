// lib/utils/app_text_styles.dart


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure google_fonts is in pubspec.yaml
import 'package:cafeteria_app/utils/app_colors.dart'; // Import your AppColors

class AppTextStyles {
  static var stylishBlackRegular;

  static var stylishOrangeDarkBold;

  // For the "Get Started" button and other bold white text
  static TextStyle get stylishWhiteBold => GoogleFonts.montserrat(
        color: AppColors.textWhite, // Using AppColors.textWhite
        fontWeight: FontWeight.bold,
        fontSize: 18,
      );

  // For stylish black bold text (e.g., on white buttons or backgrounds)
  static TextStyle get stylishBlackBold => GoogleFonts.montserrat(
        color: AppColors.textBlack, // Using AppColors.textBlack
        fontWeight: FontWeight.bold,
        fontSize: 18,
      );

  // For input placeholders on dark backgrounds (e.g., login page)
  static TextStyle get stylishWhiteInputPlaceholder => GoogleFonts.lato(
        color: AppColors.textWhite.withOpacity(0.7),
        fontSize: 16,
      );

  // For actual input text on dark backgrounds - THIS IS LIKELY 'stylishWhiteInput'
  static TextStyle get stylishWhiteInput => GoogleFonts.lato( // Renamed from stylishWhiteInputText for clarity
        color: AppColors.textWhite,
        fontSize: 16,
      );

  // For input placeholders on light backgrounds (e.g., sign up page)
  static TextStyle get stylishBlackInputPlaceholder => GoogleFonts.lato(
        color: AppColors.textBlack.withOpacity(0.6),
        fontSize: 16,
      );

  // For actual input text on light backgrounds - THIS IS LIKELY 'stylishBlackInput'
  static TextStyle get stylishBlackInput => GoogleFonts.lato( // Renamed from stylishBlackInputText for clarity
        color: AppColors.textBlack,
        fontSize: 16,
      );

  // For page titles like "Login", "Create Account"
  static TextStyle get pageTitle => GoogleFonts.pacifico(
        color: AppColors.orangePrimary, // Default color for titles
        fontSize: 36,
        fontWeight: FontWeight.normal, // Pacifico is often inherently bold
      );

  // Standard body text - white
  static TextStyle get bodyTextWhite => GoogleFonts.lato(
        color: AppColors.textWhite,
        fontSize: 16,
        height: 1.4,
      );

  // Standard body text - black
  static TextStyle get bodyTextBlack => GoogleFonts.lato(
        color: AppColors.textBlack,
        fontSize: 16,
        height: 1.4,
      );

  // Smaller text or subtitles - white
  static TextStyle get subtitleWhite => GoogleFonts.lato(
        color: AppColors.textWhite.withOpacity(0.85),
        fontSize: 14,
      );

  // Smaller text or subtitles - black
  static TextStyle get subtitleBlack => GoogleFonts.lato(
        color: AppColors.textBlack.withOpacity(0.75),
        fontSize: 14,
      );

  // For item names in lists or cards
  static TextStyle get itemName => GoogleFonts.roboto(
        color: AppColors.textBlack,
        fontWeight: FontWeight.w500,
        fontSize: 17,
      );

  // For prices
  static TextStyle get priceText => GoogleFonts.roboto(
        color: AppColors.orangeDark,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      );

  // --- Added based on your specific error messages ---

  // If you had stylishWhiteInputText and stylishBlackInputText before,
  // and now need stylishWhiteInput and stylishBlackInput, the above definitions should cover it.
  // If you need them as *additional* distinct styles, you can define them:

  static TextStyle get stylishWhiteInputText => GoogleFonts.lato( // If you had this distinct from stylishWhiteInput
        color: AppColors.textWhite,
        fontSize: 16,
  );

  static TextStyle get stylishBlackInputText => GoogleFonts.lato( // If you had this distinct from stylishBlackInput
        color: AppColors.textBlack,
        fontSize: 16,
  );

} // <--- Make sure this closing brace for the class is present and correct

// The "Expected a method, getter, setter or operator declaration." error
// often happens if there's a syntax error right before where the error is reported,
// like a missing semicolon, a misplaced brace, or an unfinished statement.
// Ensure the class structure is sound.