import 'package:melodix/features/auth/view/theme/auth_palette.dart';
import 'package:melodix/features/auth/view/widgets/eq_mark.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthBrandMark extends StatelessWidget {
  const AuthBrandMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const EqMark(height: 20),
        const SizedBox(width: 10),
        Text(
          'Melodix',
          style: GoogleFonts.fraunces(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: AuthPalette.textPrimary,
          ),
        ),
      ],
    );
  }
}
