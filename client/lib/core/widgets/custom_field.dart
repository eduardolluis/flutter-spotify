import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly,
      onTap: ontTap,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.35),
      ),
      controller: controller,
      obscureText: isObscureText,
      validator: (value) {
        if (value!.trim().isEmpty) {
          return "$hintText cannot be empty";
        }
        return null;
      },
      obscuringCharacter: '*',
    );
  }
}
