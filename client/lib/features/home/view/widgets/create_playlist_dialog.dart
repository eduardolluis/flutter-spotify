import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:melodix/core/providers/current_user_notifier.dart';
import 'package:melodix/core/providers/playlist_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/core/utils.dart';
import 'package:melodix/features/home/repositories/home_repository.dart';
import 'package:melodix/features/home/view/pages/playlist_detail_page.dart';

/// Prompts for a playlist name, creates it, and navigates to the new
/// playlist's detail page. Shared by every entry point that offers
/// "new playlist" (the Library tab and the Playlists page) so the flow
/// only has to be written once.
Future<void> showCreatePlaylistDialog(BuildContext context, WidgetRef ref) async {
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
