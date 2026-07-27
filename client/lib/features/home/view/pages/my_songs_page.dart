import 'package:cached_network_image/cached_network_image.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/view/pages/upload_song_page.dart';
import 'package:client/features/home/view/widgets/music_player.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen where each user manages (views and deletes) ONLY the songs
/// they uploaded themselves, filtering the full list by owner_id.
class MySongsPage extends ConsumerWidget {
  const MySongsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider)?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('My Songs')),
      body: ref
          .watch(getAllSongsProvider)
          .when(
            data: (songs) {
              final mine = songs.where((song) => song.owner_id == userId).toList();

              if (mine.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.music_note_list,
                          size: 56,
                          color: Pallete.subtitleText,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "You haven't uploaded any songs yet",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const UploadSongPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Pallete.cardColor,
                            foregroundColor: Pallete.whiteColor,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          icon: const Icon(CupertinoIcons.add),
                          label: const Text('Upload song'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: mine.length,
                itemBuilder: (context, index) {
                  final song = mine[index];
                  return ListTile(
                    onTap: () async {
                      await ref.read(currentSongProvider.notifier).updateSong(song);
                      if (context.mounted) MusicPlayer.open(context);
                    },
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(song.thumbnail_url),
                      radius: 25,
                      backgroundColor: Pallete.backgroundColor,
                    ),
                    title: Text(
                      song.song_name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      song.artist,
                      style: const TextStyle(fontSize: 13, color: Pallete.subtitleText),
                    ),
                    trailing: IconButton(
                      icon: const Icon(CupertinoIcons.trash, color: Pallete.errorColor),
                      onPressed: () => confirmDeleteSong(context, ref, song.id),
                    ),
                  );
                },
              );
            },
            error: (error, st) => Center(child: Text(error.toString())),
            loading: () => const Loader(),
          ),
    );
  }
}
