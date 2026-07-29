import 'dart:math';

import 'package:melodix/core/providers/current_user_notifier.dart';
import 'package:melodix/features/home/models/song_model.dart';
import 'package:melodix/features/home/repositories/home_local_repository.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_song_notifier.g.dart';

@riverpod
class IsPlaying extends _$IsPlaying {
  @override
  bool build() => false;
  void updateState(bool val) => state = val;
}

@riverpod
class Shuffle extends _$Shuffle {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

@riverpod
class Repeat extends _$Repeat {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';
  void updateQuery(String query) => state = query;
}

@riverpod
class LibrarySearchQuery extends _$LibrarySearchQuery {
  @override
  String build() => '';
  void updateQuery(String query) => state = query;
}

@riverpod
class CurrentSongNotifier extends _$CurrentSongNotifier {
  late HomeLocalRepository _homeLocalRepository;
  AudioPlayer? audioPlayer;

  /// The list of songs the currently playing song came from (a playlist,
  /// the library, search results, an artist's songs, etc). skipNext /
  /// skipPrevious walk through THIS list instead of always assuming
  /// "all songs", so playback stays consistent with wherever the user
  /// actually pressed play from.
  List<SongModel> _songsQueue = [];

  @override
  SongModel? build() {
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);

    audioPlayer = AudioPlayer();

    ref.onDispose(() {
      audioPlayer?.dispose();
    });

    return null;
  }

  Future<void> updateSong(SongModel song, {List<SongModel>? queue}) async {
    if (audioPlayer == null) return;

    if (queue != null && queue.isNotEmpty) {
      _songsQueue = queue;
    } else if (_songsQueue.indexWhere((s) => s.id == song.id) == -1) {
      _songsQueue = [song];
    }

    await audioPlayer!.stop();

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
          ref.read(isPlayingProvider.notifier).updateState(false);
          skipNext(auto: true);
        }
      }
    });

    _homeLocalRepository.uploadLocalSong(ref.read(currentUserProvider)!.id, song);

    audioPlayer!.play();
    ref.read(isPlayingProvider.notifier).updateState(true);
    state = song;
  }

  void playPause() {
    if (audioPlayer == null) return;
    final playing = ref.read(isPlayingProvider);
    if (playing) {
      audioPlayer!.pause();
    } else {
      audioPlayer!.play();
    }
    ref.read(isPlayingProvider.notifier).updateState(!playing);
  }

  void seek(double val) {
    if (audioPlayer == null || audioPlayer!.duration == null) return;
    audioPlayer!.seek(
      Duration(milliseconds: (val * audioPlayer!.duration!.inMilliseconds).toInt()),
    );
  }

  void toggleShuffle() {
    ref.read(shuffleProvider.notifier).toggle();
  }

  void toggleRepeat() {
    ref.read(repeatProvider.notifier).toggle();
  }

  List<SongModel> _queue() {
    return _songsQueue;
  }

  /// The list of songs currently queued up (whatever list the user played
  /// from: a playlist, the library, search results, etc).
  List<SongModel> get queue => List.unmodifiable(_songsQueue);

  /// Index of the currently playing song within [queue], or -1 if the
  /// current song isn't part of the tracked queue.
  int get currentQueueIndex {
    if (state == null) return -1;
    return _songsQueue.indexWhere((s) => s.id == state!.id);
  }

  /// Everything queued up to play after the current song, in play order
  /// (wraps back to the start of the queue).
  List<SongModel> get upNextSongs {
    final idx = currentQueueIndex;
    if (idx == -1 || _songsQueue.length <= 1) return [];
    return [
      for (var i = 1; i < _songsQueue.length; i++) _songsQueue[(idx + i) % _songsQueue.length],
    ];
  }

  /// Replaces what's queued up next (everything except the currently
  /// playing song) with [newUpNext] — used when the user reorders or
  /// removes songs from the queue sheet.
  void setUpNextSongs(List<SongModel> newUpNext) {
    final current = state;
    _songsQueue = [if (current != null) current, ...newUpNext];
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
