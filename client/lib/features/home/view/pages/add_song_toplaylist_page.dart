import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:melodix/core/providers/current_user_notifier.dart';
import 'package:melodix/core/providers/playlist_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/core/utils.dart';
import 'package:melodix/features/home/repositories/home_repository.dart';
import 'package:melodix/features/home/viewmodel/home_viewmodel.dart';

class AddSongsToPlaylistPage extends ConsumerStatefulWidget {
  final String playlistId;
  final Set<String> existingSongIds;

  const AddSongsToPlaylistPage({
    super.key,
    required this.playlistId,
    required this.existingSongIds,
  });

  @override
  ConsumerState<AddSongsToPlaylistPage> createState() => _AddSongsToPlaylistPageState();
}

class _AddSongsToPlaylistPageState extends ConsumerState<AddSongsToPlaylistPage> {
  final _addingIds = <String>{};
  late final _addedIds = {...widget.existingSongIds};

  Future<void> _addSong(String songId) async {
    setState(() => _addingIds.add(songId));

    final token = ref.read(currentUserProvider)!.token;
    final res = await ref
        .read(homeRepositoryProvider)
        .addSongToPlaylist(token: token, playlistId: widget.playlistId, songId: songId);

    if (!mounted) return;
    setState(() => _addingIds.remove(songId));

    switch (res) {
      case Left(value: final failure):
        showSnackBar(context, failure.message);
      case Right():
        setState(() => _addedIds.add(songId));
        ref.invalidate(playlistDetailProvider(widget.playlistId));
        ref.invalidate(playlistsProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final songsAsync = ref.watch(getAllSongsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add songs')),
      body: songsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(error.toString(), style: const TextStyle(color: Pallete.subtitleText)),
          ),
        ),
        data: (songs) {
          if (songs.isEmpty) {
            return const Center(
              child: Text('No songs available yet.', style: TextStyle(color: Pallete.subtitleText)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              final isAdded = _addedIds.contains(song.id);
              final isAdding = _addingIds.contains(song.id);

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(song.thumbnail_url),
                  radius: 24,
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
                trailing: isAdding
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        onPressed: isAdded ? null : () => _addSong(song.id),
                        icon: Icon(
                          isAdded
                              ? CupertinoIcons.checkmark_alt_circle_fill
                              : CupertinoIcons.add_circled,
                          color: isAdded ? Pallete.gradient2 : Pallete.whiteColor,
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
