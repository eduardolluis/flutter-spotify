import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodix/core/providers/current_song_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';

/// Opens a bottom sheet showing the current playback queue: the song
/// that's playing now and everything queued up to play next, in order.
/// Tapping a song in the list jumps straight to it without touching
/// the queue itself.
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

class _QueueSheet extends ConsumerWidget {
  const _QueueSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider);
    final songNotifier = ref.watch(currentSongProvider.notifier);
    final queue = songNotifier.queue;
    final currentIndex = songNotifier.currentQueueIndex;

    // Everything after the current song, wrapping back to the start,
    // excluding the current song itself — i.e. "what plays next".
    final upNext = <MapEntry<int, dynamic>>[];
    if (currentIndex != -1 && queue.length > 1) {
      for (var i = 1; i < queue.length; i++) {
        final idx = (currentIndex + i) % queue.length;
        upNext.add(MapEntry(idx, queue[idx]));
      }
    }

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
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
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
                            backgroundImage: CachedNetworkImageProvider(
                              currentSong.thumbnail_url,
                            ),
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
                      if (upNext.isNotEmpty) ...[
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
                        for (final entry in upNext)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              radius: 22,
                              backgroundColor: Pallete.backgroundColor,
                              backgroundImage: CachedNetworkImageProvider(
                                entry.value.thumbnail_url,
                              ),
                            ),
                            title: Text(
                              entry.value.song_name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              entry.value.artist,
                              style: const TextStyle(color: Pallete.subtitleText),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => songNotifier.updateSong(entry.value),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
