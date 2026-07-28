import 'package:cached_network_image/cached_network_image.dart';
import 'package:melodix/core/providers/current_user_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/core/utils.dart';
import 'package:melodix/features/auth/view/pages/signup_page.dart';
import 'package:melodix/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:melodix/features/home/view/pages/follow_list_page.dart';
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

  void _openFollowList(BuildContext context, String userId, String name, FollowListTab tab) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            FollowListPage(artistId: userId, artistName: name, initialTab: tab),
      ),
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
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Pallete.gradient1.withValues(alpha: 0.28),
                      Pallete.cardColor,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: (isUploadingAvatar || isPickingAvatar)
                              ? null
                              : () => _pickAndUploadAvatar(context, ref),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Pallete.gradient2, Pallete.gradient1],
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Pallete.backgroundColor,
                                  child: CircleAvatar(
                                    radius: 37,
                                    backgroundColor: Pallete.cardColor,
                                    backgroundImage:
                                        (user?.avatar_url != null &&
                                            user!.avatar_url!.isNotEmpty)
                                        ? CachedNetworkImageProvider(user.avatar_url!)
                                        : null,
                                    child:
                                        (user?.avatar_url == null || user!.avatar_url!.isEmpty)
                                        ? const Icon(
                                            CupertinoIcons.person_fill,
                                            size: 34,
                                            color: Pallete.subtitleText,
                                          )
                                        : null,
                                  ),
                                ),
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
                                      border: Border.fromBorderSide(
                                        BorderSide(color: Pallete.backgroundColor, width: 2),
                                      ),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.camera_fill,
                                      size: 13,
                                      color: Pallete.backgroundColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? '',
                                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                user?.email ?? '',
                                style: const TextStyle(fontSize: 12.5, color: Pallete.subtitleText),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (user != null)
                      ref
                          .watch(getArtistProfileProvider(user.id))
                          .when(
                            data: (profile) => Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _openFollowList(
                                      context,
                                      user.id,
                                      user.name,
                                      FollowListTab.followers,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: ProfileStatColumn(
                                        count: profile.followers_count,
                                        label: 'Followers',
                                      ),
                                    ),
                                  ),
                                ),
                                Container(width: 1, height: 30, color: Pallete.borderColor),
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _openFollowList(
                                      context,
                                      user.id,
                                      user.name,
                                      FollowListTab.following,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: ProfileStatColumn(
                                        count: profile.following_count,
                                        label: 'Following',
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            error: (error, stackTrace) => const SizedBox.shrink(),
                            loading: () => const SizedBox(
                              height: 44,
                              child: Center(
                                child: SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.list(
                children: [
                  _ProfileActionTile(
                    icon: CupertinoIcons.music_note_list,
                    iconColor: Pallete.gradient2,
                    label: 'My songs',
                    subtitle: 'View and manage everything you uploaded',
                    onTap: () {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (context) => const MySongsPage()));
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _ProfileActionTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

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
                    Text(
                      label,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
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
