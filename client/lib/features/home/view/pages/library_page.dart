import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/widgets/loader.dart';
import 'package:client/features/home/view/pages/upload_song_page.dart';
import 'package:client/features/home/view/widgets/music_player.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            return ListView.builder(
              itemCount: data.length + 1,
              itemBuilder: (context, index) {
                if (index == data.length) {
                  return ListTile(
                    onTap: () {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (context) => const UploadSongPage()));
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
                final song = data[index];
                return ListTile(
                  onTap: () async {
                    await ref.read(currentSongProvider.notifier).updateSong(song);
                    if (context.mounted) MusicPlayer.open(context);
                  },
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(song.thumbnail_url),
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
            );
          },
          error: (error, st) {
            return Center(child: Text(error.toString()));
          },
          loading: () => const Loader(),
        );
  }
}

/// Estado vacío amigable para cuando el usuario aún no tiene canciones
/// favoritas, en vez de dejar la pantalla en blanco o con un error.
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
              "Tu biblioteca está vacía",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Marca canciones como favoritas o sube la tuya para verlas aquí.",
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
              label: const Text("Subir canción"),
            ),
          ],
        ),
      ),
    );
  }
}
