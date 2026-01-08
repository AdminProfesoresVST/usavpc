import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // STRICTLY NAVY PALETTE - User Request "No Blue, only Navy"
  static const navyPrimary = Color(0xFF112E51);  
  static const navyDark = Color(0xFF0D2440);     
  static const surfaceWhite = Color(0xFFFFFFFF); 
  static const backgroundGrey = Color(0xFFF9FAFB); // Subtler Grey
  static const errorRed = Color(0xFFD32F2F);     // Mature Red
  
  // Exposing Action Blue for specific buttons if needed, though Navy is preferred main
  static const actionBlue = Color(0xFF005EA2);

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.publicSansTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: navyPrimary,
        onPrimary: Colors.white,
        secondary: navyPrimary, // No secondary blue
        onSecondary: Colors.white,
        surface: surfaceWhite,
        onSurface: const Color(0xFF1F2937),
        error: errorRed,

      ),
      scaffoldBackgroundColor: backgroundGrey,
      
      // Professional, Smaller Typography
      textTheme: baseTextTheme.copyWith(
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          color: navyPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 26, // Smaller
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          color: navyPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 22, // Smaller
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          color: navyPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18, // Smaller
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          color: navyPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: const Color(0xFF374151),
          fontSize: 14, // Standard readable size
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: const Color(0xFF4B5563),
          fontSize: 13, // Subtler
        ),
      ),
      
      // AppBar: Navy, Minimal
      appBarTheme: AppBarTheme(
        backgroundColor: navyPrimary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: GoogleFonts.publicSans(
          fontSize: 18, // Smaller header text
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white, size: 20),
      ),
      
      // Buttons: Navy, Subtle Shadow
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navyPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // Slightly softer rect
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Reduced Padding
          elevation: 0, // Flat design for maturity
          textStyle: GoogleFonts.publicSans(
            fontWeight: FontWeight.w500,
            fontSize: 14, // Smaller button text
          ),
        ),
      ),

      // Text Buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: navyPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: GoogleFonts.publicSans(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),

      // Cards: Very Subtle
      cardTheme: CardTheme(
        color: surfaceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade200, width: 1), // Subtle border
        ),
        elevation: 0, // Flat cards usually look more premium/modern than high elevation
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),

      // Inputs: Clean, Minimal, Small
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        isDense: true, // IMPORTANT: Makes field smaller
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Tighter padding
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        labelStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: navyPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: errorRed),
        ),
      ),
    );
  }
}
