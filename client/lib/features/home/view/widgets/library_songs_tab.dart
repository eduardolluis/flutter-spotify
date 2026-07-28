import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodix/core/providers/current_song_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/core/widgets/loader.dart';
import 'package:melodix/features/home/view/pages/upload_song_page.dart';
import 'package:melodix/features/home/view/widgets/music_player.dart';
import 'package:melodix/features/home/viewmodel/home_viewmodel.dart';

/// Favorite songs view — the Library tab's original content, with a
/// search box and an upload shortcut at the end of the list.
class LibrarySongsTab extends ConsumerWidget {
  const LibrarySongsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(librarySearchQueryProvider);

    return ref
        .watch(getFavSongsProvider)
        .when(
          data: (data) {
            if (data.isEmpty) {
              return _EmptyLibraryState(
                onUpload: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => const UploadSongPage()));
                },
              );
            }

            final filtered = query.isEmpty
                ? data
                : data
                      .where(
                        (song) =>
                            song.song_name.toLowerCase().contains(query.toLowerCase()) ||
                            song.artist.toLowerCase().contains(query.toLowerCase()),
                      )
                      .toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    onChanged: (value) =>
                        ref.read(librarySearchQueryProvider.notifier).state = value,
                    decoration: InputDecoration(
                      hintText: 'Search your library',
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
                ),
                if (filtered.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        "We couldn't find songs for your search",
                        style: TextStyle(color: Pallete.subtitleText),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: filtered.length + 1,
                      itemBuilder: (context, index) {
                        if (index == filtered.length) {
                          return ListTile(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const UploadSongPage()),
                              );
                            },
                            leading: const CircleAvatar(
                              radius: 35,
                              backgroundColor: Pallete.backgroundColor,
                              child: Icon(CupertinoIcons.plus),
                            ),
                            title: const Text(
                              "Upload New Song",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                            ),
                          );
                        }
                        final song = filtered[index];
                        return ListTile(
                          onTap: () async {
                            await ref.read(currentSongProvider.notifier).updateSong(song);
                            if (context.mounted) MusicPlayer.open(context);
                          },
                          leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(song.thumbnail_url),
                            radius: 35,
                            backgroundColor: Pallete.backgroundColor,
                          ),
                          title: Text(
                            song.song_name,
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            song.artist,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
          error: (error, st) {
            return Center(child: Text(error.toString()));
          },
          loading: () => const Loader(),
        );
  }
}

/// Friendly empty state for when the user has no favorite songs yet,
/// instead of leaving the screen blank or showing an error.
class _EmptyLibraryState extends StatelessWidget {
  final VoidCallback onUpload;

  const _EmptyLibraryState({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.heart, size: 56, color: Pallete.subtitleText),
            const SizedBox(height: 16),
            const Text(
              "Your library is empty",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Favorite songs or upload your own to see them here.",
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
              label: const Text("Upload song"),
            ),
          ],
        ),
      ),
    );
  }
}
