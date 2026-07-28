import 'package:melodix/features/auth/view/theme/auth_palette.dart';
import 'package:flutter/material.dart';

class EqMark extends StatelessWidget {
  final double height;
  final Color color;

  const EqMark({super.key, this.height = 18, this.color = AuthPalette.accent});

  static const List<double> _levels = [0.35, 0.7, 1.0, 0.55, 0.85, 0.4];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: _levels
            .map(
              (level) => Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Container(
                  width: 3,
                  height: height * level,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
