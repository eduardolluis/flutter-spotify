import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fpdart/fpdart.dart';
import 'package:melodix/core/providers/current_user_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/core/utils.dart';
import 'package:melodix/features/auth/view/pages/signup_page.dart';
import 'package:melodix/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:melodix/features/home/view/pages/settings_page.dart';
import 'package:melodix/features/home/view/widgets/profile_account_menu.dart';
import 'package:melodix/features/home/view/widgets/profile_header_card.dart';
import 'package:melodix/features/home/view/widgets/profile_library_menu.dart';

final _pickingAvatarProvider = StateProvider<bool>((ref) => false);

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _pickAndUploadAvatar(BuildContext context, WidgetRef ref) async {
    if (ref.read(_pickingAvatarProvider)) return;
    ref.read(_pickingAvatarProvider.notifier).state = true;

    try {
      final image = await pickImage();
      if (image == null) return;
      if (!context.mounted) return;

      final res = await ref.read(authViewModelProvider.notifier).updateAvatar(image);
      if (!context.mounted) return;

      switch (res) {
        case Left(value: final failure):
          showSnackBar(context, failure.message);
        case Right():
          showSnackBar(context, 'Profile picture updated');
      }
    } finally {
      ref.read(_pickingAvatarProvider.notifier).state = false;
    }
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isUploadingAvatar = ref.watch(authViewModelProvider).isLoading;
    final isPickingAvatar = ref.watch(_pickingAvatarProvider);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    ),
                    icon: const Icon(CupertinoIcons.gear_alt_fill, size: 20),
                    tooltip: 'Settings',
                  ),
                  IconButton(
                    onPressed: () => _confirmLogout(context, ref),
                    icon: const Icon(
                      CupertinoIcons.square_arrow_right,
                      color: Pallete.errorColor,
                      size: 22,
                    ),
                    tooltip: 'Log out',
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ProfileHeaderCard(
              user: user,
              isUploadingAvatar: isUploadingAvatar,
              isPickingAvatar: isPickingAvatar,
              onAvatarTap: () => _pickAndUploadAvatar(context, ref),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text("Library", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const ProfileLibraryMenu(),
                const SizedBox(height: 30),
                const Text("Account", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                ProfileAccountMenu(onLogout: () => _confirmLogout(context, ref)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
