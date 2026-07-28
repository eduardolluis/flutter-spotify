import 'package:melodix/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class CustomField extends StatefulWidget {
  final String hintText;
  final bool isObscureText;
  final bool readOnly;
  final TextEditingController? controller;
  final VoidCallback? ontTap;
  final IconData? prefixIcon;

  const CustomField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isObscureText = false,
    this.readOnly = false,
    this.ontTap,
    this.prefixIcon,
  });

  @override
  State<CustomField> createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  // Local toggle so the user can reveal their password without
  // touching the `isObscureText` contract the rest of the app relies on.
  late bool _obscured = widget.isObscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: widget.readOnly,
      onTap: widget.ontTap,
      controller: widget.controller,
      obscureText: _obscured,
      obscuringCharacter: '•',
      style: const TextStyle(color: Pallete.whiteColor, fontSize: 15, fontWeight: FontWeight.w500),
      cursorColor: Pallete.gradient2,
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        // Más contraste que antes (0.35 -> 0.5) para que se distinga
        // del fondo con imagen detrás, en vez de fundirse con él.
        fillColor: Colors.black.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        isDense: true,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, color: Pallete.subtitleText, size: 20)
            : null,
        suffixIcon: widget.isObscureText
            ? IconButton(
                onPressed: () => setState(() => _obscured = !_obscured),
                icon: Icon(
                  _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Pallete.subtitleText,
                  size: 20,
                ),
              )
            : null,
        // Ya NO seteamos `border` acá: dejamos que AppTheme.darkThemeMode
        // controle enabledBorder/focusedBorder (pill + acento azul al
        // hacer focus). Antes esto se pisaba con BorderSide.none y
        // radius distinto, por eso el campo se veía plano y sin feedback.
      ),
      validator: (value) {
        if (value!.trim().isEmpty) {
          return "${widget.hintText} cannot be empty";
        }
        return null;
      },
    );
  }
}
