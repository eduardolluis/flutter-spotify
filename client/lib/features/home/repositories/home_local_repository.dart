import 'package:client/features/home/models/song_model.dart';
import 'package:hive/hive.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_local_repository.g.dart';

@riverpod
HomeLocalRepository homeLocalRepository(Ref ref) {
  return HomeLocalRepository();
} 

class HomeLocalRepository {
  final Box box = Hive.box('songs');

  // Keys are stored as "<userId>_<songId>" so that "recently played" is
  // scoped per account and doesn't mix between different users sharing
  // the same device.
  void uploadLocalSong(String userId, SongModel song) {
    box.put('${userId}_${song.id}', song.toJson());
  }

  List<SongModel> loadSongs(String userId) {
    List<SongModel> songs = [];
    for (final key in box.keys) {
      if (key is String && key.startsWith('${userId}_')) {
        songs.add(SongModel.fromJson(box.get(key)));
      }
    }
    return songs;
  }
}
