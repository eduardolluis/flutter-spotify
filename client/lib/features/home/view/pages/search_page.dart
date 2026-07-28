import 'package:cached_network_image/cached_network_image.dart';
import 'package:melodix/core/providers/current_song_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/core/widgets/loader.dart';
import 'package:melodix/features/home/view/widgets/music_player.dart';
import 'package:melodix/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);

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
              onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
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
              child: query.isEmpty
                  ? _SearchBrowseGrid(
                      onSelectGenre: (genre) => ref.read(searchQueryProvider.notifier).state = genre,
                    )
                  : ref
                        .watch(getAllSongsProvider)
                        .when(
                          data: (songs) {
                            final filtered = songs
                                .where(
                                  (song) =>
                                      song.song_name.toLowerCase().contains(query.toLowerCase()) ||
                                      song.artist.toLowerCase().contains(query.toLowerCase()),
                                )
                                .toList();

                            if (filtered.isEmpty) {
                              return const Center(
                                child: Text(
                                  "We couldn't find anything for your search",
                                  style: TextStyle(color: Pallete.subtitleText),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.only(bottom: 100),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final song = filtered[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  onTap: () async {
                                    await ref.read(currentSongProvider.notifier).updateSong(song);
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
  final ValueChanged<String> onSelectGenre;

  const _SearchBrowseGrid({required this.onSelectGenre});

  static const _genres = [
    ('Pop', Pallete.gradient2),
    ('Hip-Hop', Pallete.gradient1),
    ('Rock', Pallete.gradient3),
    ('R&B', Pallete.gradient2),
    ('Electronic', Pallete.gradient1),
    ('Chill', Pallete.gradient3),
  ];

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
            itemCount: _genres.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.8,
            ),
            itemBuilder: (context, index) {
              final (label, color) = _genres[index];
              return Material(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onSelectGenre(label),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        label,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
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
