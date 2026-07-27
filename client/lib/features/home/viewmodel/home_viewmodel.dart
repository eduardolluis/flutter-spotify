import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:client/core/failure/failure.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/utils.dart';
import 'package:client/features/home/models/artist_profile_model.dart';
import 'package:client/features/home/models/fav_song_model.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/repositories/home_local_repository.dart';
import 'package:client/features/home/repositories/home_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_viewmodel.g.dart';

@riverpod
Future<List<SongModel>> getAllSongs(Ref ref) async {
  final token = ref.watch(currentUserProvider.select((user) => user!.token));

  final res = await ref.watch(homeRepositoryProvider).getAllSongs(token: token);

  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
}

@riverpod
Future<List<SongModel>> getFavSongs(Ref ref) async {
  final token = ref.watch(currentUserProvider.select((user) => user!.token));

  final res = await ref.watch(homeRepositoryProvider).getFavSongs(token: token);

  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
}

@riverpod
Future<ArtistProfileModel> getArtistProfile(Ref ref, String artistId) async {
  final token = ref.watch(currentUserProvider.select((user) => user!.token));

  final res = await ref
      .watch(homeRepositoryProvider)
      .getArtistProfile(token: token, artistId: artistId);

  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
}

@riverpod
class HomeViewModel extends _$HomeViewModel {
  late final HomeRepository _homeRepository;
  late final HomeLocalRepository _homeLocalRepository;

  @override
  FutureOr<dynamic> build() {
    _homeRepository = ref.watch(homeRepositoryProvider);
    _homeLocalRepository = ref.watch(homeLocalRepositoryProvider);
  }

  Future<void> uploadSong({
    required File selectedAudio,
    required File selectedThumbnail,
    required String songName,
    required String artist,
    required Color color,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(
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

  List<SongModel> getRecentlyPlayedSongs() {
    final userId = ref.read(currentUserProvider)?.id;
    if (userId == null) return [];
    return _homeLocalRepository.loadSongs(userId);
  }

  Future<void> favSong({required String songId}) async {
    final user = ref.read(currentUserProvider)!;

    final res = await _homeRepository.favSong(token: user.token, songId: songId);

    switch (res) {
      case Left(value: final l):
        state = AsyncValue.error(l.message, StackTrace.current);

      case Right(value: final r):
        _favSongSuccess(r, songId);
    }
  }

  void _favSongSuccess(bool isFavorited, String songId) {
    final user = ref.read(currentUserProvider)!;

    final userNotifier = ref.read(currentUserProvider.notifier);

    if (isFavorited) {
      userNotifier.addUser(
        user.copyWith(
          favorites: [
            ...user.favorites,

            FavSongModel(id: '', song_id: songId, user_id: ''),
          ],
        ),
      );
    } else {
      userNotifier.addUser(
        user.copyWith(favorites: user.favorites.where((e) => e.song_id != songId).toList()),
      );
    }

    ref.invalidate(getFavSongsProvider);

    state = AsyncValue.data(isFavorited);
  }

  /// Deletes a song. The server already validates that only the owner
  /// can do this, but we also hide the delete button in the UI for
  /// anyone who isn't the owner.
  Future<Either<AppFailure, String>> deleteSong(String songId) async {
    final user = ref.read(currentUserProvider)!;
    final res = await _homeRepository.deleteSong(token: user.token, songId: songId);

    if (!ref.mounted) return res;

    if (res.isRight()) {
      ref.invalidate(getAllSongsProvider);
      ref.invalidate(getFavSongsProvider);
    }

    return res;
  }

  Future<Either<AppFailure, Map<String, dynamic>>> toggleFollow(String artistId) async {
    final user = ref.read(currentUserProvider)!;
    final res = await _homeRepository.followArtist(token: user.token, artistId: artistId);

    if (!ref.mounted) return res;

    if (res.isRight()) {
      ref.invalidate(getArtistProfileProvider(artistId));
    }

    return res;
  }
}
