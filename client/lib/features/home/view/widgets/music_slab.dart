import 'package:cached_network_image/cached_network_image.dart';
import 'package:melodix/core/providers/current_song_notifier.dart';
import 'package:melodix/core/providers/current_user_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/core/utils.dart';
import 'package:melodix/features/home/view/widgets/music_player.dart';
import 'package:melodix/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicSlab extends ConsumerWidget {
  const MusicSlab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider);
    final songNotifier = ref.read(currentSongProvider.notifier);
    final isPlaying = ref.watch(isPlayingProvider);
    final userFavorites = ref.watch(currentUserProvider.select((data) => data!.favorites));
    if (currentSong == null) {
      return const SizedBox();
    }
    return GestureDetector(
      onTap: () => MusicPlayer.open(context),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 66,
            width: MediaQuery.of(context).size.width - 16,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  hexToColor(currentSong.hex_code),
                  Color.alphaBlend(
                    Colors.black.withValues(alpha: 0.35),
                    hexToColor(currentSong.hex_code),
                  ),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(9),
            child: Row(
              children: [
                Hero(
                  tag: 'music-image',
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(currentSong.thumbnail_url),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Text(
                          currentSong.song_name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Pallete.whiteColor,
                            shadows: [
                              Shadow(color: Colors.black45, offset: Offset(0, 1), blurRadius: 3),
                            ],
                          ),
                        ),
                        Text(
                          currentSong.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            color: Colors.white70,
                            shadows: [
                              Shadow(color: Colors.black45, offset: Offset(0, 1), blurRadius: 3),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        await ref
                            .read(homeViewModelProvider.notifier)
                            .favSong(songId: currentSong.id);
                      },
                      icon: Icon(
                        userFavorites.where((fav) => fav.song_id == currentSong.id).isNotEmpty
                            ? CupertinoIcons.heart_fill
                            : CupertinoIcons.heart,
                        color: Pallete.whiteColor,
                      ),
                    ),
                    IconButton(
                      onPressed: songNotifier.playPause,
                      icon: Icon(
                        isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                        color: Pallete.whiteColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          StreamBuilder(
            stream: songNotifier.audioPlayer?.positionStream,
            builder: (context, asyncSnapshot) {
              final position = asyncSnapshot.data;
              final duration = songNotifier.audioPlayer!.duration;

              double sliderValue = 0.0;
              if (position != null && duration != null) {
                sliderValue = position.inMilliseconds / duration.inMilliseconds;
              }
              return Positioned(
                bottom: 0,
                child: Container(
                  height: 2,
                  width: sliderValue * (MediaQuery.of(context).size.width - 32),
                  decoration: BoxDecoration(
                    color: Pallete.whiteColor,
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 8,
            child: Container(
              height: 2,
              width: MediaQuery.of(context).size.width - 32,
              decoration: BoxDecoration(
                color: Pallete.inactiveSeekColor,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
