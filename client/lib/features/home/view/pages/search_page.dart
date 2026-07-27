import 'package:cached_network_image/cached_network_image.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/view/widgets/music_player.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
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
            const SizedBox(height: 16),
            Expanded(
              child: query.isEmpty
                  ? const _SearchPlaceholder()
                  : ref
                        .watch(getAllSongsProvider)
                        .when(
                          data: (songs) {
                            final filtered = songs
                                .where(
                                  (song) =>
                                      song.song_name.toLowerCase().contains(
                                        query.toLowerCase(),
                                      ) ||
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
                                    await ref
                                        .read(currentSongProvider.notifier)
                                        .updateSong(song);
                                    if (context.mounted) MusicPlayer.open(context);
                                  },
                                  leading: CircleAvatar(
                                    backgroundImage: CachedNetworkImageProvider(song.thumbnail_url),
                                    radius: 25,
                                    backgroundColor: Pallete.backgroundColor,
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

/// Shown while the user hasn't typed anything yet.
class _SearchPlaceholder extends StatelessWidget {
  const _SearchPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.search, size: 56, color: Pallete.subtitleText),
            const SizedBox(height: 16),
            const Text(
              'Search for songs or artists',
              style: TextStyle(fontSize: 16, color: Pallete.subtitleText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
