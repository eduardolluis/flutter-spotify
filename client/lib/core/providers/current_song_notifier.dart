import 'dart:math';

import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_song_notifier.g.dart';

final isPlayingProvider = StateProvider<bool>((ref) => false);
final shuffleProvider = StateProvider<bool>((ref) => false);
final repeatProvider = StateProvider<bool>((ref) => false);

final searchQueryProvider = StateProvider<String>((ref) => '');
final librarySearchQueryProvider = StateProvider<String>((ref) => '');

@riverpod
class CurrentSongNotifier extends _$CurrentSongNotifier {
  late HomeLocalRepository _homeLocalRepository;
  AudioPlayer? audioPlayer;

  @override
  SongModel? build() {
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
    return null;
  }

  Future<void> updateSong(SongModel song) async {
    await audioPlayer?.stop();
    audioPlayer = AudioPlayer();

    final audioSource = AudioSource.uri(
      Uri.parse(song.song_url),
      tag: MediaItem(
        id: song.id,
        title: song.song_name,
        artist: song.artist,
        artUri: Uri.parse(song.thumbnail_url),
      ),
    );
    await audioPlayer!.setAudioSource(audioSource);

    audioPlayer!.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        if (ref.read(repeatProvider)) {
          audioPlayer!.seek(Duration.zero);
          audioPlayer!.play();
        } else {
          audioPlayer!.seek(Duration.zero);
          audioPlayer!.pause();
          ref.read(isPlayingProvider.notifier).state = false;
          skipNext(auto: true);
        }
      }
    });
    _homeLocalRepository.uploadLocalSong(ref.read(currentUserProvider)!.id, song);

    audioPlayer!.play();
    ref.read(isPlayingProvider.notifier).state = true;
    state = song;
  }

  void playPause() {
    final playing = ref.read(isPlayingProvider);
    if (playing) {
      audioPlayer!.pause();
    } else {
      audioPlayer!.play();
    }
    ref.read(isPlayingProvider.notifier).state = !playing;
  }

  void seek(double val) {
    audioPlayer!.seek(
      Duration(milliseconds: (val * audioPlayer!.duration!.inMilliseconds).toInt()),
    );
  }

  void toggleShuffle() {
    ref.read(shuffleProvider.notifier).state = !ref.read(shuffleProvider);
  }

  void toggleRepeat() {
    ref.read(repeatProvider.notifier).state = !ref.read(repeatProvider);
  }

  List<SongModel> _queue() {
    return ref.read(getAllSongsProvider).value ?? [];
  }

  void skipNext({bool auto = false}) {
    final queue = _queue();
    if (queue.isEmpty || state == null) return;

    if (ref.read(shuffleProvider)) {
      if (queue.length == 1) {
        updateSong(queue.first);
        return;
      }
      final random = Random();
      SongModel next;
      do {
        next = queue[random.nextInt(queue.length)];
      } while (next.id == state!.id);
      updateSong(next);
      return;
    }

    final currentIndex = queue.indexWhere((s) => s.id == state!.id);
    if (currentIndex == -1) {
      updateSong(queue.first);
      return;
    }
    final nextIndex = (currentIndex + 1) % queue.length;
    if (auto && nextIndex == 0 && !ref.read(repeatProvider)) return;
    updateSong(queue[nextIndex]);
  }

  void skipPrevious() {
    final queue = _queue();
    if (queue.isEmpty || state == null) return;

    final currentIndex = queue.indexWhere((s) => s.id == state!.id);
    if (currentIndex == -1) {
      updateSong(queue.first);
      return;
    }
    final prevIndex = (currentIndex - 1 + queue.length) % queue.length;
    updateSong(queue[prevIndex]);
  }
}
