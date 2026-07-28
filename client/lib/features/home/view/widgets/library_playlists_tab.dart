import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodix/core/providers/playlist_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/core/widgets/loader.dart';
import 'package:melodix/features/home/view/pages/playlist_detail_page.dart';

/// Playlists view — brings the same playlists shown on the profile page
/// into the Library tab so they're reachable from both places.
class LibraryPlaylistsTab extends ConsumerWidget {
  const LibraryPlaylistsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsProvider);

    return playlistsAsync.when(
      loading: () => const Loader(),
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
                    "Tap the + button above to create your first one.",
                    style: TextStyle(fontSize: 13, color: Pallete.subtitleText),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final playlist = playlists[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: Pallete.cardColor,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PlaylistDetailPage(playlistId: playlist.id),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Pallete.backgroundColor,
                          backgroundImage:
                              (playlist.cover_thumbnail_url != null &&
                                  playlist.cover_thumbnail_url!.isNotEmpty)
                              ? CachedNetworkImageProvider(playlist.cover_thumbnail_url!)
                              : null,
                          child: (playlist.cover_thumbnail_url == null ||
                                  playlist.cover_thumbnail_url!.isEmpty)
                              ? const Icon(CupertinoIcons.music_note_2, color: Pallete.subtitleText)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                playlist.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${playlist.song_count} song${playlist.song_count == 1 ? '' : 's'}',
                                style: const TextStyle(fontSize: 12, color: Pallete.subtitleText),
                              ),
                            ],
                          ),
                        ),
                        const Icon(CupertinoIcons.chevron_right, size: 15, color: Pallete.subtitleText),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
