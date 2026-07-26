import 'package:cached_network_image/cached_network_image.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/view/pages/upload_song_page.dart';
import 'package:client/features/home/view/widgets/libray.dart';
import 'package:client/features/home/view/widgets/music_player.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(librarySearchQueryProvider);

    return ref
        .watch(getFavSongsProvider)
        .when(
          data: (data) {
            if (data.isEmpty) {
              return EmptyLibraryState(
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
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 8),
                  child: TextField(
                    onChanged: (value) =>
                        ref.read(librarySearchQueryProvider.notifier).state = value,
                    decoration: InputDecoration(
                      hintText: 'Search your favorite songs',
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
                        'We couldn\'t find any matches for your search.',
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
