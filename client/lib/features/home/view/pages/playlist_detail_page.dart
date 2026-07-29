import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:melodix/core/providers/current_song_notifier.dart';
import 'package:melodix/core/providers/current_user_notifier.dart';
import 'package:melodix/core/providers/playlist_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/core/utils.dart';
import 'package:melodix/features/home/repositories/home_repository.dart';
import 'package:melodix/features/home/view/pages/add_song_toplaylist_page.dart'; // <-- Importación corregida según tu estructura
import 'package:melodix/features/home/view/widgets/music_player.dart';
import 'package:melodix/features/home/view/widgets/music_slab.dart';

class PlaylistDetailPage extends ConsumerWidget {
  final String playlistId;

  const PlaylistDetailPage({super.key, required this.playlistId});

  Future<void> _removeSong(BuildContext context, WidgetRef ref, String songId) async {
    final token = ref.read(currentUserProvider)!.token;
    final res = await ref
        .read(homeRepositoryProvider)
        .removeSongFromPlaylist(token: token, playlistId: playlistId, songId: songId);
    if (!context.mounted) return;

    switch (res) {
      case Left(value: final failure):
        showSnackBar(context, failure.message);
      case Right():
        ref.invalidate(playlistDetailProvider(playlistId));
        ref.invalidate(playlistsProvider);
    }
  }

  Future<void> _deletePlaylist(BuildContext context, WidgetRef ref, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Pallete.cardColor,
        title: const Text('Delete playlist'),
        content: Text('Delete "$name"? This only removes the playlist, not the songs.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Pallete.errorColor)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final token = ref.read(currentUserProvider)!.token;
    final res = await ref
        .read(homeRepositoryProvider)
        .deletePlaylist(token: token, playlistId: playlistId);
    if (!context.mounted) return;

    switch (res) {
      case Left(value: final failure):
        showSnackBar(context, failure.message);
      case Right():
        ref.invalidate(playlistsProvider);
        Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistAsync = ref.watch(playlistDetailProvider(playlistId));
    final playlist = playlistAsync.asData?.value;
    final hasCurrentSong = ref.watch(currentSongProvider) != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist?.name ?? 'Playlist'),
        actions: [
          IconButton(
            onPressed: () => _deletePlaylist(context, ref, playlist?.name ?? 'this playlist'),
            icon: const Icon(CupertinoIcons.delete, color: Pallete.errorColor),
            tooltip: 'Delete playlist',
          ),
        ],
      ),
      bottomNavigationBar: hasCurrentSong
          ? const SafeArea(
              top: false,
              child: Padding(padding: EdgeInsets.fromLTRB(12, 0, 12, 8), child: MusicSlab()),
            )
          : null,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Pallete.gradient2,
        foregroundColor: Pallete.backgroundColor,
        onPressed: () {
          final existingIds = playlist?.songs?.map((s) => s.id).toSet() ?? {};
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  AddSongsToPlaylistPage(playlistId: playlistId, existingSongIds: existingIds),
            ),
          );
        },
        icon: const Icon(CupertinoIcons.add),
        label: const Text('Add songs'),
      ),
      body: playlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(error.toString(), style: const TextStyle(color: Pallete.subtitleText)),
          ),
        ),
        data: (playlistData) {
          final songs = playlistData.songs ?? [];

          if (songs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(CupertinoIcons.music_note, size: 56, color: Pallete.subtitleText),
                    SizedBox(height: 16),
                    Text(
                      "This playlist is empty",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tap \"Add songs\" to start filling it up.",
                      style: TextStyle(fontSize: 13, color: Pallete.subtitleText),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 110),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return ListTile(
                onTap: () async {
                  await ref.read(currentSongProvider.notifier).updateSong(song, queue: songs);
                  if (context.mounted) MusicPlayer.open(context);
                },
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(song.thumbnail_url),
                  radius: 26,
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
                  onPressed: () => _removeSong(context, ref, song.id),
                  icon: const Icon(
                    CupertinoIcons.minus_circle,
                    size: 20,
                    color: Pallete.subtitleText,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
