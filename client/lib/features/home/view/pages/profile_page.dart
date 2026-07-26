import 'package:cached_network_image/cached_network_image.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/auth/view/pages/signup_page.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:client/features/home/view/pages/my_songs_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fpdart/fpdart.dart';

class ProfilePage extends ConsumerWidget {
  ProfilePage({super.key});
  final pickingAvatarProvider = StateProvider<bool>((ref) => false);

  Future<void> pickAndUploadAvatar(BuildContext context, WidgetRef ref) async {
    if (ref.read(pickingAvatarProvider)) return;
    ref.read(pickingAvatarProvider.notifier).state = true;

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
          showSnackBar(context, 'Foto de perfil actualizada');
      }
    } finally {
      ref.read(pickingAvatarProvider.notifier).state = false;
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Pallete.cardColor,
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Log Out', style: TextStyle(color: Pallete.errorColor)),
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
    final isPicking = ref.watch(pickingAvatarProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Profile', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: (isUploadingAvatar || isPicking)
                          ? null
                          : () => pickAndUploadAvatar(context, ref),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: Pallete.cardColor,
                            backgroundImage:
                                (user?.avatar_url != null && user!.avatar_url!.isNotEmpty)
                                ? CachedNetworkImageProvider(user.avatar_url!)
                                : null,
                            child: (user?.avatar_url == null || user!.avatar_url!.isEmpty)
                                ? const Icon(
                                    CupertinoIcons.person_fill,
                                    size: 48,
                                    color: Pallete.subtitleText,
                                  )
                                : null,
                          ),
                          if (isUploadingAvatar)
                            const CircularProgressIndicator(color: Pallete.whiteColor)
                          else
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Pallete.gradient2,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.camera_fill,
                                  size: 16,
                                  color: Pallete.whiteColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? '',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(fontSize: 14, color: Pallete.subtitleText),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Divider(color: Pallete.borderColor),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(CupertinoIcons.music_note_list, color: Pallete.whiteColor),
                title: const Text('My songs', style: TextStyle(fontWeight: FontWeight.w600)),
                trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => const MySongsPage()));
                },
              ),
              const Divider(color: Pallete.borderColor),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(CupertinoIcons.square_arrow_right, color: Pallete.errorColor),
                title: const Text(
                  'Log Out',
                  style: TextStyle(color: Pallete.errorColor, fontWeight: FontWeight.w600),
                ),
                onTap: () => _confirmLogout(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
