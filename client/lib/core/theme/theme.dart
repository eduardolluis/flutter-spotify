import 'package:client/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderSide: BorderSide(color: color, width: 1.5),
    borderRadius: BorderRadius.circular(100), // fully rounded (pill) fields, everywhere
  );

  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: Pallete.backgroundColor,
    textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      enabledBorder: _border(Pallete.borderColor),
      focusedBorder: _border(Pallete.gradient2),
      hintStyle: GoogleFonts.montserrat(color: Pallete.subtitleText, fontSize: 15),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Pallete.backgroundColor,
    ),
  );
}
