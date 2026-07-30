import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodix/core/providers/current_user_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/core/utils.dart';
import 'package:melodix/features/auth/view/pages/signup_page.dart';
import 'package:melodix/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:melodix/features/home/view/pages/edit_profile_page.dart';
import 'package:melodix/features/home/view/widgets/profile_action_tile.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _clearImageCache(BuildContext context) async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    showSnackBar(context, 'Image cache cleared');
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Pallete.cardColor,
          title: const Text('Log out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Log out', style: TextStyle(color: Pallete.errorColor)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    await ref.read(authViewModelProvider.notifier).logout();

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SignupPage()),
      (route) => false,
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Pallete.cardColor,
        title: const Text('About Melodix'),
        content: const Text(
          'Melodix is a place to upload, discover and listen to music from independent artists.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          const Text('Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ProfileActionTile(
            icon: CupertinoIcons.person_fill,
            iconColor: Pallete.gradient2,
            label: user?.name ?? '',
            subtitle: user?.email ?? '',
            onTap: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
          ),
          const SizedBox(height: 28),
          const Text('Storage', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ProfileActionTile(
            icon: CupertinoIcons.trash,
            iconColor: Colors.orange,
            label: 'Clear image cache',
            subtitle: 'Frees up space used by cached thumbnails and avatars',
            onTap: () => _clearImageCache(context),
          ),
          const SizedBox(height: 28),
          const Text('About', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ProfileActionTile(
            icon: CupertinoIcons.info_circle_fill,
            iconColor: Pallete.gradient3,
            label: 'About Melodix',
            subtitle: 'Version 1.0.0',
            onTap: () => _showAbout(context),
          ),
          const SizedBox(height: 28),
          const Text('Session', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ProfileActionTile(
            icon: CupertinoIcons.square_arrow_right,
            iconColor: Colors.redAccent,
            label: 'Log out',
            subtitle: 'Sign out of Melodix',
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }
}
