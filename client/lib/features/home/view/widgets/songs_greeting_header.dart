import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melodix/core/models/user_model.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/features/home/view/pages/profile_page.dart';

class _ProfilePageRoute extends StatelessWidget {
  const _ProfilePageRoute();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Pallete.backgroundColor,
      body: ProfilePage(),
    );
  }
}

/// Avatar + time-of-day greeting shown at the top of the Home feed.
/// Tapping it opens the Profile page.
class SongsGreetingHeader extends StatelessWidget {
  final UserModel? user;

  const SongsGreetingHeader({super.key, required this.user});

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const _ProfilePageRoute()));
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Pallete.borderColor, width: 1.5),
              ),
              child: CircleAvatar(
                radius: 19,
                backgroundColor: Pallete.cardColor,
                backgroundImage: (user?.avatar_url != null && user!.avatar_url!.isNotEmpty)
                    ? CachedNetworkImageProvider(user!.avatar_url!)
                    : null,
                child: (user?.avatar_url == null || user!.avatar_url!.isEmpty)
                    ? const Icon(CupertinoIcons.person_fill, size: 18, color: Pallete.subtitleText)
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Pallete.subtitleText,
                    letterSpacing: 0.2,
                    height: 1.3,
                  ),
                ),
                Text(
                  user?.name.split(' ').first ?? '',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
