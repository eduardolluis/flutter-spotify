import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodix/core/providers/current_song_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/features/home/models/song_model.dart';

/// Opens a bottom sheet showing the current playback queue: the song
/// that's playing now, and everything queued up to play next — which
/// the user can reorder (drag the handle) or remove (swipe left).
void showQueueSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Pallete.cardColor,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => const _QueueSheet(),
  );
}

class _QueueSheet extends ConsumerStatefulWidget {
  const _QueueSheet();

  @override
  ConsumerState<_QueueSheet> createState() => _QueueSheetState();
}

class _QueueSheetState extends ConsumerState<_QueueSheet> {
  late List<SongModel> _upNext;

  @override
  void initState() {
    super.initState();
    _upNext = List.of(ref.read(currentSongProvider.notifier).upNextSongs);
  }

  void _persist() {
    ref.read(currentSongProvider.notifier).setUpNextSongs(_upNext);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) newIndex -= 1;
      final song = _upNext.removeAt(oldIndex);
      _upNext.insert(newIndex, song);
    });
    _persist();
  }

  void _onRemove(SongModel song) {
    setState(() {
      _upNext.removeWhere((s) => s.id == song.id);
    });
    _persist();
  }

  Future<void> _playFromQueue(SongModel song) async {
    await ref.read(currentSongProvider.notifier).updateSong(song);
    if (!mounted) return;
    setState(() {
      _upNext = List.of(ref.read(currentSongProvider.notifier).upNextSongs);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = ref.watch(currentSongProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
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
                const Text(
                  'Playing queue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (currentSong != null) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      'NOW PLAYING',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Pallete.gradient2,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Pallete.backgroundColor,
                      backgroundImage: CachedNetworkImageProvider(currentSong.thumbnail_url),
                    ),
                    title: Text(
                      currentSong.song_name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      currentSong.artist,
                      style: const TextStyle(color: Pallete.subtitleText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(
                      CupertinoIcons.speaker_2_fill,
                      color: Pallete.gradient2,
                      size: 18,
                    ),
                  ),
                ],
                if (_upNext.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(top: 12, bottom: 6),
                    child: Text(
                      'UP NEXT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Pallete.subtitleText,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ReorderableListView.builder(
                      scrollController: scrollController,
                      buildDefaultDragHandles: false,
                      itemCount: _upNext.length,
                      onReorder: _onReorder,
                      itemBuilder: (context, index) {
                        final song = _upNext[index];
                        return Dismissible(
                          key: ValueKey(song.id),
                          direction: DismissDirection.startToEnd,
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Pallete.errorColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(CupertinoIcons.delete, color: Colors.white),
                          ),

                          onDismissed: (_) => _onRemove(song),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundColor: Pallete.backgroundColor,
                              backgroundImage: CachedNetworkImageProvider(song.thumbnail_url),
                            ),
                            title: Text(
                              song.song_name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              song.artist,
                              style: const TextStyle(color: Pallete.subtitleText),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => _playFromQueue(song),
                            trailing: ReorderableDragStartListener(
                              index: index,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  CupertinoIcons.line_horizontal_3,
                                  color: Pallete.subtitleText,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ] else if (currentSong != null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'Nothing else queued up yet.',
                      style: TextStyle(color: Pallete.subtitleText),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
