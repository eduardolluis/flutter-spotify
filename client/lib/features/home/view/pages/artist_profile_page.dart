import 'package:cached_network_image/cached_network_image.dart';
import 'package:melodix/core/providers/current_song_notifier.dart';
import 'package:melodix/core/providers/current_user_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/core/utils.dart';
import 'package:melodix/core/widgets/loader.dart';
import 'package:melodix/features/home/view/pages/follow_list_page.dart';
import 'package:melodix/features/home/view/widgets/music_player.dart';
import 'package:melodix/features/home/view/widgets/profile_stat_column.dart';
import 'package:melodix/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

class ArtistProfilePage extends ConsumerStatefulWidget {
  final String artistId;
  final String artistName;

  const ArtistProfilePage({super.key, required this.artistId, required this.artistName});

  @override
  ConsumerState<ArtistProfilePage> createState() => _ArtistProfilePageState();
}

class _ArtistProfilePageState extends ConsumerState<ArtistProfilePage> {
  bool _isTogglingFollow = false;

  Future<void> _toggleFollow() async {
    if (_isTogglingFollow) return;
    setState(() => _isTogglingFollow = true);

    final res = await ref.read(homeViewModelProvider.notifier).toggleFollow(widget.artistId);

    if (!mounted) return;
    setState(() => _isTogglingFollow = false);

    switch (res) {
      case Left(value: final failure):
        showSnackBar(context, failure.message);
      case Right():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = ref.watch(currentUserProvider)?.id;
    final userFavorites = ref.watch(currentUserProvider.select((data) => data?.favorites ?? []));
    final isOwnProfile = currentUserId == widget.artistId;

    return Scaffold(
      body: ref
          .watch(getArtistProfileProvider(widget.artistId))
          .when(
            data: (artist) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 210,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 140,
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
                          SafeArea(
                            bottom: false,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: const Icon(CupertinoIcons.back),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            top: 90,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Pallete.backgroundColor,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 48,
                                backgroundColor: Pallete.cardColor,
                                backgroundImage:
                                    (artist.avatar_url != null && artist.avatar_url!.isNotEmpty)
                                    ? CachedNetworkImageProvider(artist.avatar_url!)
                                    : null,
                                child: (artist.avatar_url == null || artist.avatar_url!.isEmpty)
                                    ? const Icon(
                                        CupertinoIcons.person_fill,
                                        size: 44,
                                        color: Pallete.subtitleText,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            artist.name.isNotEmpty ? artist.name : widget.artistName,
                            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Pallete.cardColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => FollowListPage(
                                          artistId: widget.artistId,
                                          artistName: artist.name.isNotEmpty
                                              ? artist.name
                                              : widget.artistName,
                                          initialTab: FollowListTab.followers,
                                        ),
                                      ),
                                    ),
                                    child: ProfileStatColumn(
                                      count: artist.followers_count,
                                      label: 'Followers',
                                    ),
                                  ),
                                ),
                                Container(width: 1, height: 28, color: Pallete.borderColor),
                                Expanded(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => FollowListPage(
                                          artistId: widget.artistId,
                                          artistName: artist.name.isNotEmpty
                                              ? artist.name
                                              : widget.artistName,
                                          initialTab: FollowListTab.following,
                                        ),
                                      ),
                                    ),
                                    child: ProfileStatColumn(
                                      count: artist.following_count,
                                      label: 'Following',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isOwnProfile) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isTogglingFollow ? null : _toggleFollow,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: artist.is_following
                                      ? Pallete.cardColor
                                      : Pallete.gradient2,
                                  foregroundColor: artist.is_following
                                      ? Pallete.whiteColor
                                      : Pallete.backgroundColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                child: _isTogglingFollow
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Text(
                                        artist.is_following ? 'Following' : 'Follow',
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Songs',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  if (artist.songs.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                          child: Text(
                            "This artist hasn't uploaded any songs yet",
                            style: TextStyle(color: Pallete.subtitleText),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
                      sliver: SliverList.builder(
                        itemCount: artist.songs.length,
                        itemBuilder: (context, index) {
                          final song = artist.songs[index];
                          final isFavorite = userFavorites.any((f) => f.song_id == song.id);

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            onTap: () async {
                              await ref
                                  .read(currentSongProvider.notifier)
                                  .updateSong(song, queue: artist.songs);
                              if (context.mounted) MusicPlayer.open(context);
                            },
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: song.thumbnail_url,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              song.song_name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artist,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Pallete.subtitleText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                ref.read(homeViewModelProvider.notifier).favSong(songId: song.id);
                              },
                              icon: Icon(
                                isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                                color: isFavorite ? Pallete.gradient2 : Pallete.whiteColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
            error: (error, stackTrace) {
              return Center(child: Text(error.toString()));
            },
            loading: () => const Loader(),
          ),
    );
  }
}
