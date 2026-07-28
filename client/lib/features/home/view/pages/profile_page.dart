import 'package:cached_network_image/cached_network_image.dart';
import 'package:melodix/core/providers/current_user_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/core/utils.dart';
import 'package:melodix/features/auth/view/pages/signup_page.dart';
import 'package:melodix/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:melodix/features/home/view/pages/my_songs_page.dart';
import 'package:melodix/features/home/view/widgets/profile_stat_column.dart';
import 'package:melodix/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fpdart/fpdart.dart';

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

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 168,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 108,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Pallete.gradient1.withValues(alpha: 0.9),
                            Pallete.backgroundColor,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      top: 16,
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Pallete.whiteColor.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      top: 56,
                      child: GestureDetector(
                        onTap: (isUploadingAvatar || isPickingAvatar)
                            ? null
                            : () => _pickAndUploadAvatar(context, ref),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Pallete.backgroundColor,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 44,
                                backgroundColor: Pallete.cardColor,
                                backgroundImage:
                                    (user?.avatar_url != null && user!.avatar_url!.isNotEmpty)
                                    ? CachedNetworkImageProvider(user.avatar_url!)
                                    : null,
                                child: (user?.avatar_url == null || user!.avatar_url!.isEmpty)
                                    ? const Icon(
                                        CupertinoIcons.person_fill,
                                        size: 40,
                                        color: Pallete.subtitleText,
                                      )
                                    : null,
                              ),
                            ),
                            if (isUploadingAvatar)
                              const CircularProgressIndicator(color: Pallete.whiteColor)
                            else
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Pallete.gradient2,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.camera_fill,
                                    size: 14,
                                    color: Pallete.backgroundColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? '',
                      style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(fontSize: 13, color: Pallete.subtitleText),
                    ),
                    const SizedBox(height: 20),
                    if (user != null)
                      ref
                          .watch(getArtistProfileProvider(user.id))
                          .when(
                            data: (profile) => Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Pallete.cardColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ProfileStatColumn(
                                      count: profile.followers_count,
                                      label: 'Followers',
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 28,
                                    color: Pallete.borderColor,
                                  ),
                                  Expanded(
                                    child: ProfileStatColumn(
                                      count: profile.following_count,
                                      label: 'Following',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            error: (error, stackTrace) => const SizedBox.shrink(),
                            loading: () => const SizedBox(
                              height: 20,
                              child: Center(
                                child: SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(height: 28),
                    _ProfileActionTile(
                      icon: CupertinoIcons.music_note_list,
                      iconColor: Pallete.gradient2,
                      label: 'My songs',
                      onTap: () {
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(builder: (context) => const MySongsPage()));
                      },
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmLogout(context, ref),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Pallete.errorColor,
                          side: const BorderSide(color: Pallete.errorColor),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                        ),
                        icon: const Icon(CupertinoIcons.square_arrow_right, size: 18),
                        label: const Text('Log out', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _ProfileActionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Pallete.cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
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
