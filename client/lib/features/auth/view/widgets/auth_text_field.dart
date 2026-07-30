import 'package:melodix/features/auth/view/theme/auth_palette.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isObscureText;
  final bool isEmail;
  final TextInputType keyboardType;

  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isObscureText = false,
    this.isEmail = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscured = widget.isObscureText;
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.4,
            color: _focused ? AuthPalette.accent : AuthPalette.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          focusNode: _focusNode,
          controller: widget.controller,
          obscureText: _obscured,
          obscuringCharacter: '•',
          keyboardType: widget.keyboardType,
          textAlignVertical: TextAlignVertical.bottom,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AuthPalette.textPrimary,
          ),
          cursorColor: AuthPalette.accent,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.only(bottom: 8),
            suffixIconConstraints: const BoxConstraints(minWidth: 26, minHeight: 26),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: AuthPalette.hairline, width: 1),
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AuthPalette.hairline, width: 1),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AuthPalette.accent, width: 1.5),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AuthPalette.error, width: 1),
            ),
            suffixIcon: widget.isObscureText
                ? IconButton(
                    onPressed: () => setState(() => _obscured = !_obscured),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    visualDensity: VisualDensity.compact,
                    splashRadius: 16,
                    icon: Icon(
                      _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AuthPalette.textMuted,
                      size: 17,
                    ),
                  )
                : null,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '${widget.label} is required';
            }
            if (widget.isEmail) {
              final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Enter a valid email';
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}
