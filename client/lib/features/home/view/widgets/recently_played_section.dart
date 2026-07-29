import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melodix/core/providers/current_song_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/features/home/models/song_model.dart';
import 'package:melodix/features/home/view/widgets/music_player.dart';
import 'package:melodix/features/home/view/widgets/section_header.dart';

/// "Recently played" row of compact song cards on the Home feed.
/// Renders nothing when there's no recent history.
class RecentlyPlayedSection extends ConsumerWidget {
  final List<SongModel> songs;

  const RecentlyPlayedSection({super.key, required this.songs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (songs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SectionHeader('Recently played'),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 10) / 2;
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: songs.map((song) {
                  return SizedBox(
                    width: cardWidth,
                    height: 64,
                    child: GestureDetector(
                      onTap: () async {
                        await ref
                            .read(currentSongProvider.notifier)
                            .updateSong(song, queue: songs);
                        if (context.mounted) MusicPlayer.open(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Pallete.cardColor.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Pallete.borderColor.withValues(alpha: 0.6),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 50,
                              height: double.infinity,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(11),
                                  bottomLeft: Radius.circular(11),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: song.thumbnail_url,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                song.song_name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
