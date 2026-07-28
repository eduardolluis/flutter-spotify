import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodix/core/models/user_model.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/features/home/view/pages/follow_list_page.dart';
import 'package:melodix/features/home/view/widgets/profile_stat_column.dart';
import 'package:melodix/features/home/view/widgets/vinyl_avatar.dart';
import 'package:melodix/features/home/viewmodel/home_viewmodel.dart';

/// The card at the top of the Profile page: avatar (tap to change),
/// name, email, and the followers/following stat row.
class ProfileHeaderCard extends ConsumerWidget {
  final UserModel? user;
  final bool isUploadingAvatar;
  final bool isPickingAvatar;
  final VoidCallback onAvatarTap;

  const ProfileHeaderCard({
    super.key,
    required this.user,
    required this.isUploadingAvatar,
    required this.isPickingAvatar,
    required this.onAvatarTap,
  });

  void _openFollowList(BuildContext context, String userId, String name, FollowListTab tab) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FollowListPage(artistId: userId, artistName: name, initialTab: tab),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
                onTap: (isUploadingAvatar || isPickingAvatar) ? null : onAvatarTap,
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
                .watch(getArtistProfileProvider(user!.id))
                .when(
                  data: (profile) => Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _openFollowList(
                            context,
                            user!.id,
                            user!.name,
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
                            user!.id,
                            user!.name,
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
    );
  }
}
