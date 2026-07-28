import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melodix/core/theme/app_pallete.dart';

class VinylAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double size;

  const VinylAvatar({super.key, required this.avatarUrl, this.size = 88});

  @override
  Widget build(BuildContext context) {
    final labelSize = size * 0.6;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size(size, size), painter: _VinylDiscPainter()),
          Container(
            width: labelSize,
            height: labelSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Pallete.backgroundColor,
              border: Border.all(color: Pallete.gradient2, width: 1.4),
            ),
            child: ClipOval(
              child: (avatarUrl != null && avatarUrl!.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: avatarUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          const Icon(CupertinoIcons.person_fill, color: Pallete.subtitleText),
                    )
                  : const Icon(CupertinoIcons.person_fill, color: Pallete.subtitleText, size: 22),
            ),
          ),
          Container(
            width: size * 0.055,
            height: size * 0.055,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Pallete.backgroundColor),
          ),
        ],
      ),
    );
  }
}

class _VinylDiscPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.width / 2;

    canvas.drawCircle(center, maxRadius, Paint()..color = const Color(0xFF0A0A0C));

    final groovePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const grooveCount = 4;
    for (var i = 0; i < grooveCount; i++) {
      final radius = maxRadius * (0.66 + i * 0.085);
      groovePaint.color = Pallete.borderColor.withValues(alpha: 0.85 - i * 0.15);
      canvas.drawCircle(center, radius, groovePaint);
    }

    final sheenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.white.withValues(alpha: 0.06), Colors.white.withValues(alpha: 0.0)],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius));
    canvas.drawCircle(center, maxRadius, sheenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
