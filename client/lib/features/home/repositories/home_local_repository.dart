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

  // Las claves se guardan como "<userId>_<songId>" para que "recientemente
  // escuchado" quede ligado a cada cuenta y no se mezcle entre usuarios
  // distintos que usan el mismo dispositivo.
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
