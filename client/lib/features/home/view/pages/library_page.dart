import 'package:cached_network_image/cached_network_image.dart';
import 'package:melodix/core/providers/current_song_notifier.dart';
import 'package:melodix/core/providers/current_user_notifier.dart';
import 'package:melodix/core/providers/playlist_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/core/utils.dart';
import 'package:melodix/core/widgets/loader.dart';
import 'package:melodix/features/home/repositories/home_repository.dart';
import 'package:melodix/features/home/view/pages/playlist_detail_page.dart';
import 'package:melodix/features/home/view/pages/upload_song_page.dart';
import 'package:melodix/features/home/view/widgets/music_player.dart';
import 'package:melodix/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

enum _LibrarySegment { songs, playlists }

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  _LibrarySegment segment = _LibrarySegment.songs;

  Future<void> _createPlaylist(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Pallete.cardColor,
        title: const Text('New playlist'),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Pallete.whiteColor),
          decoration: const InputDecoration(hintText: 'Playlist name'),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Create', style: TextStyle(color: Pallete.gradient2)),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;
    if (!context.mounted) return;

    final token = ref.read(currentUserProvider)!.token;
    final res = await ref.read(homeRepositoryProvider).createPlaylist(token: token, name: name);
    if (!context.mounted) return;

    switch (res) {
      case Left(value: final failure):
        showSnackBar(context, failure.message);
      case Right(value: final playlist):
        ref.invalidate(playlistsProvider);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PlaylistDetailPage(playlistId: playlist.id)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 70, 16, 12),
          child: _LibrarySegmentedControl(
            segment: segment,
            onChanged: (value) => setState(() => segment = value),
            onAddPlaylist: () => _createPlaylist(context, ref),
          ),
        ),
        Expanded(
          child: segment == _LibrarySegment.songs ? const _SongsTab() : const _PlaylistsTab(),
        ),
      ],
    );
  }
}

class _LibrarySegmentedControl extends StatelessWidget {
  final _LibrarySegment segment;
  final ValueChanged<_LibrarySegment> onChanged;
  final VoidCallback onAddPlaylist;

  const _LibrarySegmentedControl({
    required this.segment,
    required this.onChanged,
    required this.onAddPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Pallete.borderColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SegmentButton(
                    label: 'Songs',
                    icon: CupertinoIcons.heart_fill,
                    selected: segment == _LibrarySegment.songs,
                    onTap: () => onChanged(_LibrarySegment.songs),
                  ),
                ),
                Expanded(
                  child: _SegmentButton(
                    label: 'Playlists',
                    icon: CupertinoIcons.music_note_list,
                    selected: segment == _LibrarySegment.playlists,
                    onTap: () => onChanged(_LibrarySegment.playlists),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: segment == _LibrarySegment.playlists
              ? Padding(
                  key: const ValueKey('add-playlist'),
                  padding: const EdgeInsets.only(left: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onAddPlaylist,
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Pallete.gradient2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(CupertinoIcons.add, color: Pallete.backgroundColor),
                    ),
                  ),
                )
              : const SizedBox(key: ValueKey('no-add'), width: 0),
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? Pallete.cardColor : Pallete.transparentColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Pallete.transparentColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 15, color: selected ? Pallete.whiteColor : Pallete.subtitleText),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? Pallete.whiteColor : Pallete.subtitleText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Favorite songs view — this is the library page's original content.
class _SongsTab extends ConsumerWidget {
  const _SongsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(librarySearchQueryProvider);

    return ref
        .watch(getFavSongsProvider)
        .when(
          data: (data) {
            if (data.isEmpty) {
              return _EmptyLibraryState(
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
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    onChanged: (value) =>
                        ref.read(librarySearchQueryProvider.notifier).state = value,
                    decoration: InputDecoration(
                      hintText: 'Search your library',
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
                        "We couldn't find songs for your search",
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

/// Playlists view — brings the same playlists shown on the profile page
/// into the Library tab so they're reachable from both places.
class _PlaylistsTab extends ConsumerWidget {
  const _PlaylistsTab();

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
                  const Icon(CupertinoIcons.music_note_list, size: 56, color: Pallete.subtitleText),
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
                          child:
                              (playlist.cover_thumbnail_url == null ||
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
                        const Icon(
                          CupertinoIcons.chevron_right,
                          size: 15,
                          color: Pallete.subtitleText,
                        ),
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

/// Friendly empty state for when the user has no favorite songs yet,
/// instead of leaving the screen blank or showing an error.
class _EmptyLibraryState extends StatelessWidget {
  final VoidCallback onUpload;

  const _EmptyLibraryState({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.heart, size: 56, color: Pallete.subtitleText),
            const SizedBox(height: 16),
            const Text(
              "Your library is empty",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Favorite songs or upload your own to see them here.",
              style: TextStyle(fontSize: 13, color: Pallete.subtitleText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: Pallete.cardColor,
                foregroundColor: Pallete.whiteColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
              icon: const Icon(CupertinoIcons.add),
              label: const Text("Upload song"),
            ),
          ],
        ),
      ),
    );
  }
}
