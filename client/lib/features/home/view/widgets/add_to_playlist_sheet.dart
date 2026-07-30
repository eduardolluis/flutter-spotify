import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:melodix/core/providers/current_user_notifier.dart';
import 'package:melodix/core/providers/playlist_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/core/utils.dart';
import 'package:melodix/features/home/models/playlist_model.dart';
import 'package:melodix/features/home/models/song_model.dart';
import 'package:melodix/features/home/repositories/home_repository.dart';

/// Opens a bottom sheet that lets the user add [song] to one of their
/// existing playlists, or create a brand-new playlist that starts with
/// that song already in it.
void showAddToPlaylistSheet(BuildContext context, WidgetRef ref, SongModel song) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Pallete.cardColor,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
    builder: (sheetContext) => _AddToPlaylistSheet(song: song),
  );
}

class _AddToPlaylistSheet extends ConsumerStatefulWidget {
  final SongModel song;

  const _AddToPlaylistSheet({required this.song});

  @override
  ConsumerState<_AddToPlaylistSheet> createState() => _AddToPlaylistSheetState();
}

class _AddToPlaylistSheetState extends ConsumerState<_AddToPlaylistSheet> {
  final _addingIds = <String>{};
  final _addedIds = <String>{};
  bool _creating = false;

  Future<void> _addToExisting(PlaylistModel playlist) async {
    setState(() => _addingIds.add(playlist.id));

    final token = ref.read(currentUserProvider)!.token;
    final res = await ref
        .read(homeRepositoryProvider)
        .addSongToPlaylist(token: token, playlistId: playlist.id, songId: widget.song.id);

    if (!mounted) return;
    setState(() => _addingIds.remove(playlist.id));

    switch (res) {
      case Left(value: final failure):
        showSnackBar(context, failure.message);
      case Right():
        setState(() => _addedIds.add(playlist.id));
        ref.invalidate(playlistDetailProvider(playlist.id));
        ref.invalidate(playlistsProvider);
        showSnackBar(context, 'Added to "${playlist.name}"');
    }
  }

  Future<void> _createAndAdd() async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Pallete.cardColor,
        title: const Text('New playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Pallete.whiteColor),
          decoration: const InputDecoration(hintText: 'Playlist name'),
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Create', style: TextStyle(color: Pallete.gradient2)),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;
    if (!mounted) return;

    setState(() => _creating = true);

    final token = ref.read(currentUserProvider)!.token;
    final repo = ref.read(homeRepositoryProvider);
    final createRes = await repo.createPlaylist(token: token, name: name);

    switch (createRes) {
      case Left(value: final failure):
        if (!mounted) return;
        setState(() => _creating = false);
        showSnackBar(context, failure.message);
      case Right(value: final playlist):
        final addRes = await repo.addSongToPlaylist(
          token: token,
          playlistId: playlist.id,
          songId: widget.song.id,
        );
        if (!mounted) return;
        setState(() => _creating = false);
        ref.invalidate(playlistsProvider);

        switch (addRes) {
          case Left(value: final failure):
            showSnackBar(context, failure.message);
          case Right():
            ref.invalidate(playlistDetailProvider(playlist.id));
            if (mounted) Navigator.of(context).pop();
            showSnackBar(context, 'Created "$name" and added the song');
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlistsAsync = ref.watch(playlistsProvider);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Pallete.borderColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add "${widget.song.song_name}" to playlist',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Pallete.backgroundColor,
                child: Icon(CupertinoIcons.add, color: Pallete.whiteColor),
              ),
              title: const Text('New playlist', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: _creating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: _creating ? null : _createAndAdd,
            ),
            const Divider(color: Pallete.borderColor, height: 24),
            Flexible(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: playlistsAsync.when(
                  data: (playlists) {
                    if (playlists.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            "You don't have any playlists yet — create one above.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Pallete.subtitleText),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = playlists[index];
                        final isAdded = _addedIds.contains(playlist.id);
                        final isAdding = _addingIds.contains(playlist.id);

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: Pallete.backgroundColor,
                            backgroundImage:
                                (playlist.cover_thumbnail_url != null &&
                                    playlist.cover_thumbnail_url!.isNotEmpty)
                                ? NetworkImage(playlist.cover_thumbnail_url!)
                                : null,
                            child: (playlist.cover_thumbnail_url == null)
                                ? const Icon(
                                    CupertinoIcons.music_note_2,
                                    color: Pallete.subtitleText,
                                  )
                                : null,
                          ),
                          title: Text(
                            playlist.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${playlist.song_count} song${playlist.song_count == 1 ? '' : 's'}',
                            style: const TextStyle(fontSize: 12, color: Pallete.subtitleText),
                          ),
                          trailing: isAdding
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(
                                  isAdded
                                      ? CupertinoIcons.checkmark_alt_circle_fill
                                      : CupertinoIcons.add_circled,
                                  color: isAdded ? Pallete.gradient2 : Pallete.whiteColor,
                                ),
                          onTap: isAdded ? null : () => _addToExisting(playlist),
                        );
                      },
                    );
                  },
                  error: (error, stackTrace) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        error.toString(),
                        style: const TextStyle(color: Pallete.subtitleText),
                      ),
                    ),
                  ),
                  loading: () => const SizedBox(
                    height: 140,
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
