import 'package:cached_network_image/cached_network_image.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicPlayer extends ConsumerWidget {
  const MusicPlayer({super.key});

  /// Honest feedback for features that do not exist yet (connect
  /// device, playlists), instead of leaving the icon unresponsive.
  static void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature: coming soon 👀'), duration: const Duration(seconds: 1)),
    );
  }

  /// the mini player (MusicSlab), so it can be reused from anywhere
  /// the user taps a song.
  static void open(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const MusicPlayer();
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween(
            begin: Offset(1, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeIn));
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider);
    final songNotifier = ref.watch(currentSongProvider.notifier);
    final isPlaying = ref.watch(isPlayingProvider);
    final shuffleOn = ref.watch(shuffleProvider);
    final repeatOn = ref.watch(repeatProvider);
    final userFavorites = ref.watch(currentUserProvider.select((data) => data!.favorites));

    if (currentSong == null || songNotifier.audioPlayer == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [hexToColor(currentSong.hex_code), const Color(0xff121212)],
        ),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 24),
          child: Scaffold(
            backgroundColor: Pallete.transparentColor,
            appBar: AppBar(
              backgroundColor: Pallete.transparentColor,
              leading: Transform.translate(
                offset: const Offset(-15, 0),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(
                    'assets/images/pull-down-arrow.png',
                    color: Pallete.whiteColor,
                  ),
                ),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Hero(
                      tag: 'music-image',
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(currentSong.thumbnail_url),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentSong.song_name,
                                style: TextStyle(
                                  color: Pallete.whiteColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                currentSong.artist,
                                style: TextStyle(
                                  color: Pallete.subtitleText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const Expanded(child: SizedBox()),
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
                        ],
                      ),
                      const SizedBox(height: 15),
                      StreamBuilder(
                        stream: songNotifier.audioPlayer!.positionStream,
                        builder: (context, asyncSnapshot) {
                          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox();
                          }
                          final position = asyncSnapshot.data;
                          final duration = songNotifier.audioPlayer!.duration;

                          double sliderValue = 0.0;
                          if (position != null && duration != null) {
                            sliderValue = position.inMilliseconds / duration.inMilliseconds;
                          }
                          return Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Pallete.whiteColor,
                                  inactiveTrackColor: Pallete.whiteColor.withValues(alpha: 0.117),
                                  thumbColor: Pallete.whiteColor,
                                  trackHeight: 4,
                                  overlayShape: SliderComponentShape.noOverlay,
                                ),
                                child: Slider(
                                  value: sliderValue,
                                  min: 0,
                                  max: 1,
                                  onChanged: (val) {
                                    sliderValue = val;
                                  },
                                  onChangeEnd: songNotifier.seek,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${position?.inMinutes}:${(position?.inSeconds ?? 0) < 10 ? "0${position?.inSeconds}" : "${position?.inSeconds}"}',
                                    style: TextStyle(
                                      color: Pallete.subtitleText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Expanded(child: SizedBox()),
                                  Text(
                                    '${duration?.inMinutes}:${(duration?.inSeconds ?? 0) < 10 ? "0${duration?.inSeconds}" : "${duration?.inSeconds}"}',
                                    style: TextStyle(
                                      color: Pallete.subtitleText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: songNotifier.toggleShuffle,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(
                                'assets/images/shuffle.png',
                                width: 24,
                                height: 24,
                                color: shuffleOn ? Pallete.gradient2 : Pallete.whiteColor,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: songNotifier.skipPrevious,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(
                                'assets/images/previus-song.png',
                                width: 24,
                                height: 24,
                                color: Pallete.whiteColor,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: songNotifier.playPause,
                            icon: Icon(
                              isPlaying
                                  ? CupertinoIcons.pause_circle_fill
                                  : CupertinoIcons.play_circle_fill,
                            ),
                            iconSize: 64,
                            color: Pallete.whiteColor,
                          ),
                          GestureDetector(
                            onTap: songNotifier.skipNext,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(
                                'assets/images/next-song.png',
                                width: 24,
                                height: 24,
                                color: Pallete.whiteColor,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: songNotifier.toggleRepeat,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(
                                'assets/images/repeat.png',
                                width: 24,
                                height: 24,
                                color: repeatOn ? Pallete.gradient2 : Pallete.whiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _comingSoon(context, 'Connect device'),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(
                                'assets/images/connect-device.png',
                                width: 22,
                                height: 22,
                                color: Pallete.whiteColor,
                              ),
                            ),
                          ),
                          const Expanded(child: SizedBox()),
                          GestureDetector(
                            onTap: () => _comingSoon(context, 'Playlists'),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(
                                'assets/images/playlist.png',
                                width: 22,
                                height: 22,
                                color: Pallete.whiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
