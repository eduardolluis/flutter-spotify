import 'package:cached_network_image/cached_network_image.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/view/pages/empty_song.dart';
import 'package:client/features/home/view/pages/profile_page.dart';
import 'package:client/features/home/view/pages/upload_song_page.dart';
import 'package:client/features/home/view/widgets/artists.dart';
import 'package:client/features/home/view/widgets/music_player.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SongsPage extends ConsumerWidget {
  const SongsPage({super.key});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          // Header de Perfil
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => const ProfilePage()));
              },
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Pallete.cardColor,
                    backgroundImage: (user?.avatar_url != null && user!.avatar_url!.isNotEmpty)
                        ? CachedNetworkImageProvider(user.avatar_url!)
                        : null,
                    child: (user?.avatar_url == null || user!.avatar_url!.isEmpty)
                        ? const Icon(
                            CupertinoIcons.person_fill,
                            size: 20,
                            color: Pallete.subtitleText,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Hello, ${user?.name.split(' ').first ?? ''}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recently Played Section
                  if (recentlyPlayedSongs.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Recently played",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final cardWidth = (constraints.maxWidth - 10) / 2;
                          return Wrap(
                            spacing: 10,
                            runSpacing: 8,
                            children: recentlyPlayedSongs.map((song) {
                              return SizedBox(
                                width: cardWidth,
                                height: 62,
                                child: GestureDetector(
                                  onTap: () async {
                                    await ref.read(currentSongProvider.notifier).updateSong(song);
                                    if (context.mounted) MusicPlayer.open(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Pallete.cardColor.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 48,
                                          height: double.infinity,
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(6),
                                              bottomLeft: Radius.circular(6),
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
                    const SizedBox(height: 30),
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
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "Latest today",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 12),
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
                                          left: index == 0 ? 16 : 12,
                                          right: index == songs.length - 1 ? 16 : 0,
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
                                                borderRadius: BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              width: 155,
                                              child: Text(
                                                song.song_name,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            SizedBox(
                                              width: 155,
                                              child: Text(
                                                song.artist,
                                                style: const TextStyle(
                                                  color: Pallete.subtitleText,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
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
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  const SizedBox(height: 110),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
