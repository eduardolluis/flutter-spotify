import 'package:cached_network_image/cached_network_image.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/view/pages/profile_page.dart';
import 'package:client/features/home/view/pages/search_page.dart';
import 'package:client/features/home/view/pages/upload_song_page.dart';
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
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
                    const SizedBox(width: 10),
                    Text(
                      'Hola, ${user?.name.split(' ').first ?? ''}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Solo mostramos "reproducidas recientemente" si hay algo que mostrar
            if (recentlyPlayedSongs.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 36),
                child: GridView.builder(
                  // shrinkWrap y NeverScrollableScrollPhysics permiten al GridView
                  // calcular su tamaño exacto dentro de una Column.
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: recentlyPlayedSongs.length,
                  itemBuilder: (context, index) {
                    final song = recentlyPlayedSongs[index];
                    return GestureDetector(
                      onTap: () async {
                        await ref.read(currentSongProvider.notifier).updateSong(song);
                        if (context.mounted) MusicPlayer.open(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Pallete.borderColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.only(right: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  bottomLeft: Radius.circular(4),
                                ),
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(song.thumbnail_url),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                song.song_name,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
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
            ref
                .watch(getAllSongsProvider)
                .when(
                  data: (songs) {
                    if (songs.isEmpty) {
                      return _EmptySongsState(
                        onUpload: () {
                          Navigator.of(
                            context,
                          ).push(MaterialPageRoute(builder: (context) => const UploadSongPage()));
                        },
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Latest today",
                            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(
                          height: 260,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: songs.length,
                            itemBuilder: (context, index) {
                              final song = songs[index];
                              return GestureDetector(
                                onTap: () async {
                                  await ref.read(currentSongProvider.notifier).updateSong(song);
                                  if (context.mounted) MusicPlayer.open(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 180,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: CachedNetworkImageProvider(song.thumbnail_url),
                                            fit: BoxFit.contain,
                                          ),
                                          borderRadius: BorderRadius.circular(7),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          song.song_name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 180,
                                        child: Text(
                                          song.artist,
                                          style: const TextStyle(
                                            color: Pallete.subtitleText,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 32),
                        _ArtistsSection(songs: songs),
                      ],
                    );
                  },
                  error: (error, stackTrace) {
                    return Center(child: Text(error.toString()));
                  },
                  loading: () => const Loader(),
                ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

/// Muestra los artistas (derivados de las canciones que ya existen, ya
/// que todavía no hay una tabla de "artistas" propia) debajo de
/// "Latest today". Cada nuevo artista aparece automáticamente en cuanto
/// alguien sube una canción suya.
class _ArtistsSection extends ConsumerWidget {
  final List<dynamic> songs;

  const _ArtistsSection({required this.songs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Un thumbnail representativo por artista (el de su primera canción).
    final artistThumbnails = <String, String>{};
    for (final song in songs) {
      artistThumbnails.putIfAbsent(song.artist, () => song.thumbnail_url);
    }
    final artists = artistThumbnails.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Artists', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w700)),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: artists.length,
            itemBuilder: (context, index) {
              final artist = artists[index];
              return GestureDetector(
                onTap: () {
                  ref.read(searchQueryProvider.notifier).state = artist;
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => const SearchPage()));
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Pallete.borderColor,
                        backgroundImage: CachedNetworkImageProvider(artistThumbnails[artist]!),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 90,
                        child: Text(
                          artist,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Estado vacío amigable que se muestra cuando el usuario todavía
/// no tiene ninguna canción subida, en vez de dejar "Latest today"
/// con una lista vacía y fría.
class _EmptySongsState extends StatelessWidget {
  final VoidCallback onUpload;

  const _EmptySongsState({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          const Icon(CupertinoIcons.music_note_2, size: 56, color: Pallete.subtitleText),
          const SizedBox(height: 16),
          const Text(
            "Aún no tienes canciones",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Sube tu primera canción para empezar a armar tu biblioteca.",
            style: TextStyle(fontSize: 13, color: Pallete.subtitleText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: Pallete.cardColor,
              foregroundColor: Pallete.whiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            icon: const Icon(CupertinoIcons.add),
            label: const Text("Subir canción"),
          ),
        ],
      ),
    );
  }
}
