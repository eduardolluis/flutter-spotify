import 'package:melodix/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class ProfileStatColumn extends StatelessWidget {
  final int count;
  final String label;

  const ProfileStatColumn({super.key, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$count', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 13, color: Pallete.subtitleText)),
      ],
    );
  }
}
