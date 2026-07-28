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
import 'package:melodix/features/home/view/pages/edit_profile_page.dart';
import 'package:melodix/features/home/view/pages/follow_list_page.dart';
import 'package:melodix/features/home/view/pages/library_page.dart';
import 'package:melodix/features/home/view/pages/my_songs_page.dart';
import 'package:melodix/features/home/view/pages/playlists_page.dart';
import 'package:melodix/features/home/view/pages/settings_page.dart';
import 'package:melodix/features/home/view/pages/upload_song_page.dart';
import 'package:melodix/features/home/view/widgets/profile_action_tile.dart';
import 'package:melodix/features/home/view/widgets/profile_stat_column.dart';
import 'package:melodix/features/home/view/widgets/vinyl_avatar.dart';
import 'package:melodix/features/home/view/widgets/vinyl_track_tile.dart';
import 'package:melodix/features/home/viewmodel/home_viewmodel.dart';

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
        builder: (context) => FollowListPage(artistId: userId, artistName: name, initialTab: tab),
      ),
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
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Pallete.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
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
                            VinylAvatar(avatarUrl: user?.avatar_url, size: 88),
                            if (isUploadingAvatar)
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withValues(alpha: 0.45),
                                ),
                                child: const CircularProgressIndicator(color: Pallete.whiteColor),
                              )
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
                                      BorderSide(color: Pallete.cardColor, width: 2),
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
                            const Text(
                              'PROFILE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.4,
                                color: Pallete.subtitleText,
                              ),
                            ),
                            const SizedBox(height: 4),
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
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text("Library", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Pallete.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      VinylTrackTile(
                        index: '01',
                        icon: CupertinoIcons.music_note_2,
                        title: 'My Songs',
                        subtitle: 'Manage uploads',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MySongsPage()),
                          );
                        },
                      ),
                      const Divider(height: 1, color: Colors.white10),
                      VinylTrackTile(
                        index: '02',
                        icon: CupertinoIcons.cloud_upload_fill,
                        title: 'Upload',
                        subtitle: 'Share music',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const UploadSongPage()),
                          );
                        },
                      ),
                      const Divider(height: 1, color: Colors.white10),
                      VinylTrackTile(
                        index: '03',
                        icon: CupertinoIcons.heart_fill,
                        title: 'Favorites',
                        subtitle: 'Liked tracks',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(title: const Text('Favorites')),
                                body: const LibraryPage(),
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1, color: Colors.white10),
                      VinylTrackTile(
                        index: '04',
                        icon: CupertinoIcons.gear_alt_fill,
                        title: 'Settings',
                        subtitle: 'Preferences',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SettingsPage()),
                          );
                        },
                      ),
                      const Divider(height: 1, color: Colors.white10),
                      VinylTrackTile(
                        index: '05',
                        icon: CupertinoIcons.music_note_list,
                        title: 'Playlists',
                        subtitle: 'Your custom mixes',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PlaylistsPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text("Account", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                ProfileActionTile(
                  icon: CupertinoIcons.person_crop_circle_fill,
                  iconColor: Pallete.gradient2,
                  label: "Edit profile",
                  subtitle: "Change your avatar and information",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfilePage()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                ProfileActionTile(
                  icon: CupertinoIcons.square_arrow_right,
                  iconColor: Colors.redAccent,
                  label: "Log out",
                  subtitle: "Sign out of Melodix",
                  onTap: () => _confirmLogout(context, ref),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
