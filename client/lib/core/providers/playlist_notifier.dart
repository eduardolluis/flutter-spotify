import 'package:melodix/core/providers/current_user_notifier.dart';
import 'package:melodix/features/home/models/playlist_model.dart';
import 'package:melodix/features/home/repositories/home_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fpdart/fpdart.dart';

part 'playlist_notifier.g.dart';

@riverpod
Future<List<PlaylistModel>> playlists(Ref ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw 'User not logged in';

  final res = await ref.watch(homeRepositoryProvider).getPlaylists(token: user.token);

  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
}

@riverpod
Future<PlaylistModel> playlistDetail(Ref ref, String playlistId) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) throw 'User not logged in';

  final res = await ref
      .watch(homeRepositoryProvider)
      .getPlaylist(token: user.token, playlistId: playlistId);

  return switch (res) {
    Left(value: final l) => throw l.message,
    Right(value: final r) => r,
  };
}
