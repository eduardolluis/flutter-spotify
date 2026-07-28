import 'package:flutter/material.dart';

class AuthPalette {
  AuthPalette._();

  static const Color ink = Color(0xFF0E0D10); // background, warm near-black
  static const Color surface = Color(0xFF17161B); // panel fill, solid — no glass/blur
  static const Color hairline = Color(0xFF2E2A30); // borders, dividers
  static const Color hairlineStrong = Color(0xFF423C45);

  static const Color accent = Color.fromRGBO(111, 168, 232, 1); // = Pallete.gradient2 (brand blue)
  static const Color accentDim = Color.fromRGBO(47, 98, 199, 1); // = Pallete.gradient1

  static const Color textPrimary = Color(0xFFF4EFE6); // warm off-white
  static const Color textMuted = Color(0xFF8B8790);
  static const Color textFaint = Color(0xFF5B5760);

  static const Color error = Color(0xFFD9695A);
}
