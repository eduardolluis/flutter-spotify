import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melodix/core/theme/app_pallete.dart';

class ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const ProfileActionTile({super.key, required this.icon, required this.iconColor, required this.label, this.subtitle, required this.onTap});

 
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Pallete.cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(fontSize: 12, color: Pallete.subtitleText),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(CupertinoIcons.chevron_right, size: 16, color: Pallete.subtitleText),
            ],
          ),
        ),
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickActionCard({super.key, 
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Pallete.cardColor,
      borderRadius: BorderRadius.circular(24),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          height: 145,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),

              const Spacer(),

              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),

              const SizedBox(height: 4),

              Text(subtitle, style: const TextStyle(color: Pallete.subtitleText, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
