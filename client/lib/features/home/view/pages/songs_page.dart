  import 'package:cached_network_image/cached_network_image.dart';
  import 'package:melodix/core/providers/current_song_notifier.dart';
  import 'package:melodix/core/providers/current_user_notifier.dart';
  import 'package:melodix/core/theme/app_pallete.dart';
  import 'package:melodix/core/utils.dart';
  import 'package:melodix/core/widgets/loader.dart';
  import 'package:melodix/features/home/view/pages/empty_song.dart';
  import 'package:melodix/features/home/view/pages/profile_page.dart';
  import 'package:melodix/features/home/view/pages/upload_song_page.dart';
  import 'package:melodix/features/home/view/widgets/artists.dart';
  import 'package:melodix/features/home/view/widgets/music_player.dart';
  import 'package:melodix/features/home/viewmodel/home_viewmodel.dart';
  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';

  class SongsPage extends ConsumerWidget {
    const SongsPage({super.key});

    static String _greeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) return 'Good morning';
      if (hour < 18) return 'Good afternoon';
      return 'Good evening';
    }

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final recentlyPlayedSongs = ref.watch(homeViewModelProvider.notifier).getRecentlyPlayedSongs();
      final currentSong = ref.watch(currentSongProvider);
      final user = ref.watch(currentUserProvider);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: currentSong == null
            ? null
            : BoxDecoration(
                gradient: LinearGradient(
                  colors: [hexToColor(currentSong.hex_code), Pallete.backgroundColor],
                  stops: const [0.0, 0.3],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(builder: (context) => const ProfilePage()));
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
                              ? CachedNetworkImageProvider(user.avatar_url!)
                              : null,
                          child: (user?.avatar_url == null || user!.avatar_url!.isEmpty)
                              ? const Icon(
                                  CupertinoIcons.person_fill,
                                  size: 18,
                                  color: Pallete.subtitleText,
                                )
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
              ),
              const SizedBox(height: 24),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recently Played Section
                    if (recentlyPlayedSongs.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: _SectionHeader('Recently played'),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final cardWidth = (constraints.maxWidth - 10) / 2;
                            return Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: recentlyPlayedSongs.map((song) {
                                return SizedBox(
                                  width: cardWidth,
                                  height: 64,
                                  child: GestureDetector(
                                    onTap: () async {
                                      await ref.read(currentSongProvider.notifier).updateSong(song);
                                      if (context.mounted) MusicPlayer.open(context);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Pallete.cardColor.withValues(alpha: 0.7),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Pallete.borderColor.withValues(alpha: 0.6),
                                          width: 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.25),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 50,
                                            height: double.infinity,
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(11),
                                                bottomLeft: Radius.circular(11),
                                              ),
                                              child: CachedNetworkImage(
                                                imageUrl: song.thumbnail_url,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Flexible(
                                            child: Text(
                                              song.song_name,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                height: 1.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // All Songs / Latest Today Section
                    ref
                        .watch(getAllSongsProvider)
                        .when(
                          data: (songs) {
                            if (songs.isEmpty) {
                              return EmptySongsState(
                                onUpload: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const UploadSongPage()),
                                  );
                                },
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: _SectionHeader('Latest today'),
                                ),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height: 240,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: songs.length,
                                    itemBuilder: (context, index) {
                                      final song = songs[index];
                                      return GestureDetector(
                                        onTap: () async {
                                          await ref
                                              .read(currentSongProvider.notifier)
                                              .updateSong(song);
                                          if (context.mounted) MusicPlayer.open(context);
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            left: index == 0 ? 20 : 12,
                                            right: index == songs.length - 1 ? 20 : 0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 155,
                                                height: 155,
                                                decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                    image: CachedNetworkImageProvider(
                                                      song.thumbnail_url,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Pallete.borderColor.withValues(alpha: 0.5),
                                                    width: 1,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withValues(alpha: 0.3),
                                                      blurRadius: 10,
                                                      offset: const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              SizedBox(
                                                width: 155,
                                                child: Text(
                                                  song.song_name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    height: 1.25,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              SizedBox(
                                                width: 155,
                                                child: Text(
                                                  song.artist,
                                                  style: const TextStyle(
                                                    color: Pallete.subtitleText,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.25,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: ArtistsSection(songs: songs),
                                ),
                              ],
                            );
                          },
                          error: (error, stackTrace) {
                            return Center(child: Text(error.toString()));
                          },
                          loading: () => const Loader(),
                        ),
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      );
    }
  }

  /// Consistent section title style used across the Home feed, so
  /// "Recently played", "Latest today", etc. never drift out of sync.
  class _SectionHeader extends StatelessWidget {
    final String title;
    const _SectionHeader(this.title);

    @override
    Widget build(BuildContext context) {
      return Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          height: 1.2,
        ),
      );
    }
  }