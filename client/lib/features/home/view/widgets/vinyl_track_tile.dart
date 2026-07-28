import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melodix/core/theme/app_pallete.dart';

class VinylTrackTile extends StatelessWidget {
  final String index;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const VinylTrackTile({
    super.key,
    required this.index,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: Text(
                  index,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Pallete.subtitleText,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(icon, size: 19, color: Pallete.gradient2),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Pallete.subtitleText),
                    ),
                  ],
                ),
              ),
              const Icon(CupertinoIcons.chevron_right, size: 15, color: Pallete.subtitleText),
            ],
          ),
        ),
      ),
    );
  }
}
