import 'dart:math';

import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:client/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_song_notifier.g.dart';

/// Estado de reproducción (play/pause), shuffle y repeat como
/// StateProviders simples: NO necesitan generación de código
/// (build_runner), así que evitan cualquier problema con el .g.dart.
///
/// SongModel tiene igualdad por valor (operator ==), así que antes,
/// reasignar `state = state?.copyWith(...)` con los mismos valores no
/// disparaba un rebuild en Riverpod (el framework veía el nuevo estado
/// como "igual" al anterior y no notificaba a los widgets). Por eso el
/// ícono de play/pause se quedaba pegado. Estos providers aparte sí
/// cambian de forma confiable.
final isPlayingProvider = StateProvider<bool>((ref) => false);
final shuffleProvider = StateProvider<bool>((ref) => false);
final repeatProvider = StateProvider<bool>((ref) => false);

/// Texto de búsqueda para cada pantalla. Van separados porque el usuario
/// puede estar buscando algo distinto en Search y en Library al mismo tiempo.
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

  /// Cola de canciones usada para "siguiente"/"anterior": la lista completa
  /// de canciones ya cargada. Si todavía no cargó, no hace nada.
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
    // En modo automático (la canción terminó sola), si ya no hay una
    // "siguiente" real (llegamos al final) y no hay repeat, simplemente
    // nos quedamos pausados en la última en vez de reiniciar el ciclo.
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
