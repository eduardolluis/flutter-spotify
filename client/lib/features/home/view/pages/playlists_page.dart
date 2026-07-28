import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodix/core/providers/playlist_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/features/home/view/pages/playlist_detail_page.dart';
import 'package:melodix/features/home/view/widgets/create_playlist_dialog.dart';

class PlaylistsPage extends ConsumerWidget {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Playlists')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Pallete.gradient2,
        foregroundColor: Pallete.backgroundColor,
        onPressed: () => showCreatePlaylistDialog(context, ref),
        child: const Icon(CupertinoIcons.add),
      ),
      body: playlistsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(error.toString(), style: const TextStyle(color: Pallete.subtitleText)),
          ),
        ),
        data: (playlists) {
          if (playlists.isEmpty) {
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
                      "You don't have any playlists yet",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tap the + button to create your first one.",
                      style: TextStyle(fontSize: 13, color: Pallete.subtitleText),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PlaylistDetailPage(playlistId: playlist.id)),
                  );
                },
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: Pallete.cardColor,
                  backgroundImage:
                      (playlist.cover_thumbnail_url != null &&
                          playlist.cover_thumbnail_url!.isNotEmpty)
                      ? CachedNetworkImageProvider(playlist.cover_thumbnail_url!)
                      : null,
                  child: (playlist.cover_thumbnail_url == null)
                      ? const Icon(CupertinoIcons.music_note_2, color: Pallete.subtitleText)
                      : null,
                ),
                title: Text(
                  playlist.name,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${playlist.song_count} song${playlist.song_count == 1 ? '' : 's'}',
                  style: const TextStyle(fontSize: 12, color: Pallete.subtitleText),
                ),
                trailing: const Icon(CupertinoIcons.chevron_right, size: 15),
              );
            },
          );
        },
      ),
    );
  }
}
