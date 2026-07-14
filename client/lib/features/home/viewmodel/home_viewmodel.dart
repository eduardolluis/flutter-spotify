import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/repositories/home_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_viewmodel.g.dart';

@riverpod
class HomeViewModel extends _$HomeViewModel {
  late final HomeRepository _homeRepository;

  @override
  FutureOr<Map<String, dynamic>?> build() {
    _homeRepository = ref.watch(homeRepositoryProvider);
    return null;
  }

  Future<void> uploadSong({
    required File selectedAudio,
    required File selectedThumbnail,
    required String songName,
    required String artist,
    required Color color,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard<Map<String, dynamic>>(
      () => _homeRepository.uploadSong(
        song: selectedAudio,
        thumbnail: selectedThumbnail,
        artist: artist,
        songName: songName,
        hexCode: rgbToHex(color),
        token: ref.read(currentUserProvider)!.token,
      ),
    );
  }
}
