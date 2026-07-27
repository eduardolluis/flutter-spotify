import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final String hintText;
  final bool isObscureText;
  final bool readOnly;
  final TextEditingController? controller;
  final VoidCallback? ontTap;

  const CustomField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isObscureText = false,
    this.readOnly = false,
    this.ontTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly,
      onTap: ontTap,
      controller: controller,
      obscureText: isObscureText,
      obscuringCharacter: '*',
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.35),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        isDense: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (value!.trim().isEmpty) {
          return "$hintText cannot be empty";
        }
        return null;
      },
    );
  }
}
