import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodix/features/home/view/widgets/create_playlist_dialog.dart';
import 'package:melodix/features/home/view/widgets/library_playlists_tab.dart';
import 'package:melodix/features/home/view/widgets/library_segmented_control.dart';
import 'package:melodix/features/home/view/widgets/library_songs_tab.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  LibrarySegment segment = LibrarySegment.songs;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 70, 16, 12),
          child: LibrarySegmentedControl(
            segment: segment,
            onChanged: (value) => setState(() => segment = value),
            onAddPlaylist: () => showCreatePlaylistDialog(context, ref),
          ),
        ),
        Expanded(
          child: segment == LibrarySegment.songs
              ? const LibrarySongsTab()
              : const LibraryPlaylistsTab(),
        ),
      ],
    );
  }
}
