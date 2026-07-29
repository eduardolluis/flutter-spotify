import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:melodix/core/constants/genres.dart';
import 'package:melodix/core/providers/current_song_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/core/widgets/loader.dart';
import 'package:melodix/features/home/models/song_model.dart';
import 'package:melodix/features/home/view/pages/artist_profile_page.dart';
import 'package:melodix/features/home/view/widgets/music_player.dart';
import 'package:melodix/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedGenreProvider = StateProvider<Genre?>((ref) => null);

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final selectedGenre = ref.watch(selectedGenreProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text('Search', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              autofocus: false,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
                if (value.isNotEmpty) {
                  ref.read(selectedGenreProvider.notifier).state = null;
                }
              },
              decoration: InputDecoration(
                hintText: 'Songs, artists...',
                prefixIcon: const Icon(CupertinoIcons.search),
                filled: true,
                fillColor: Pallete.borderColor,
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: query.isEmpty && selectedGenre == null
                  ? _SearchBrowseGrid(
                      onSelectGenre: (genre) =>
                          ref.read(selectedGenreProvider.notifier).state = genre,
                    )
                  : ref
                        .watch(getAllSongsProvider)
                        .when(
                          data: (songs) {
                            final filtered = songs.where((song) {
                              final matchesGenre =
                                  selectedGenre == null ||
                                  (song.genre ?? '').toLowerCase() ==
                                      selectedGenre.label.toLowerCase();
                              final matchesQuery =
                                  query.isEmpty ||
                                  song.song_name.toLowerCase().contains(query.toLowerCase()) ||
                                  song.artist.toLowerCase().contains(query.toLowerCase());
                              return matchesGenre && matchesQuery;
                            }).toList();

                            final matchingArtists = <SongModel>[];
                            if (query.isNotEmpty) {
                              final seenArtists = <String>{};
                              for (final song in songs) {
                                if (song.owner_id == null) continue;
                                if (!song.artist.toLowerCase().contains(query.toLowerCase())) {
                                  continue;
                                }
                                if (seenArtists.add(song.artist)) {
                                  matchingArtists.add(song);
                                }
                              }
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (selectedGenre != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: selectedGenre.color.withValues(alpha: 0.18),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            selectedGenre.icon,
                                            size: 16,
                                            color: selectedGenre.color,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          selectedGenre.label,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const Spacer(),
                                        TextButton(
                                          onPressed: () =>
                                              ref.read(selectedGenreProvider.notifier).state = null,
                                          child: const Text('Clear'),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (matchingArtists.isNotEmpty) ...[
                                  const Text(
                                    'Artists',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 96,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: matchingArtists.length,
                                      itemBuilder: (context, index) {
                                        final artistSong = matchingArtists[index];
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            right: index == matchingArtists.length - 1 ? 0 : 16,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => ArtistProfilePage(
                                                    artistId: artistSong.owner_id!,
                                                    artistName: artistSong.artist,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Column(
                                              children: [
                                                CircleAvatar(
                                                  radius: 28,
                                                  backgroundColor: Pallete.borderColor,
                                                  backgroundImage:
                                                      (artistSong.artist_avatar_url != null &&
                                                          artistSong.artist_avatar_url!.isNotEmpty)
                                                      ? CachedNetworkImageProvider(
                                                          artistSong.artist_avatar_url!,
                                                        )
                                                      : null,
                                                  child:
                                                      (artistSong.artist_avatar_url == null ||
                                                          artistSong.artist_avatar_url!.isEmpty)
                                                      ? const Icon(
                                                          CupertinoIcons.person_fill,
                                                          size: 24,
                                                          color: Pallete.subtitleText,
                                                        )
                                                      : null,
                                                ),
                                                const SizedBox(height: 6),
                                                SizedBox(
                                                  width: 72,
                                                  child: Text(
                                                    artistSong.artist,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                    ),
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
                                  const SizedBox(height: 20),
                                  const Text(
                                    'Songs',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                                Expanded(
                                  child: filtered.isEmpty
                                      ? const Center(
                                          child: Text(
                                            "We couldn't find anything for your search",
                                            style: TextStyle(color: Pallete.subtitleText),
                                            textAlign: TextAlign.center,
                                          ),
                                        )
                                      : ListView.builder(
                                          padding: const EdgeInsets.only(bottom: 100),
                                          itemCount: filtered.length,
                                          itemBuilder: (context, index) {
                                            final song = filtered[index];
                                            return ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              onTap: () async {
                                                await ref
                                                    .read(currentSongProvider.notifier)
                                                    .updateSong(song, queue: filtered);
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
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              subtitle: Text(
                                                song.artist,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: Pallete.subtitleText,
                                                ),
                                              ),
                                              trailing: const Icon(
                                                CupertinoIcons.play_fill,
                                                size: 18,
                                                color: Pallete.subtitleText,
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            );
                          },
                          error: (error, st) => Center(child: Text(error.toString())),
                          loading: () => const Loader(),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBrowseGrid extends StatelessWidget {
  final ValueChanged<Genre> onSelectGenre;

  const _SearchBrowseGrid({required this.onSelectGenre});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Browse all', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: kGenres.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.8,
            ),
            itemBuilder: (context, index) {
              final genre = kGenres[index];
              return Material(
                color: genre.color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onSelectGenre(genre),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Icon(
                            genre.icon,
                            size: 34,
                            color: genre.color.withValues(alpha: 0.55),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            genre.label,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
