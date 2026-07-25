import 'dart:convert';
import 'dart:io';

import 'package:client/core/constants/server_constants.dart';
import 'package:client/core/failure/failure.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_repository.g.dart';

@riverpod
HomeRepository homeRepository(Ref ref) {
  return HomeRepository();
}

class HomeRepository {
  Future<Map<String, dynamic>> uploadSong({
    required File song,
    required File thumbnail,
    required String artist,
    required String songName,
    required String hexCode,
    required String token,
  }) async {
    final request =
        http.MultipartRequest('POST', Uri.parse('${ServerConstants.serverURL}/song/upload'))
          ..headers['x-auth-token'] = token
          ..fields.addAll({'artist': artist, 'song_name': songName, 'hex_code': hexCode})
          ..files.addAll([
            await http.MultipartFile.fromPath('song', song.path),
            await http.MultipartFile.fromPath('thumbnail', thumbnail.path),
          ]);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201) {
      throw Exception(body['detail'] ?? 'Could not upload song');
    }

    return body;
  }

  Future<Either<AppFailure, List<SongModel>>> getAllSongs({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse('${ServerConstants.serverURL}/song/list'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );
      var resBodyMap = jsonDecode(res.body);

      if (res.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(AppFailure(resBodyMap['detail']));
      }
      resBodyMap = resBodyMap as List;

      List<SongModel> songs = [];
      for (final map in resBodyMap) {
        songs.add(SongModel.fromMap(map));
      }
      return Right(songs);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, bool>> favSong({required String token, required String songId}) async {
    try {
      final res = await http.post(
        Uri.parse('${ServerConstants.serverURL}/song/favorite'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({'song_id': songId}),
      );
      var resBodyMap = jsonDecode(res.body);

      if (res.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(AppFailure(resBodyMap['detail']));
      }
      return Right(resBodyMap['is_favorite']);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, List<SongModel>>> getFavSongs({required String token}) async {
    try {
      final res = await http.get(
        Uri.parse('${ServerConstants.serverURL}/song/list/favorites'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );
      var resBodyMap = jsonDecode(res.body);

      if (res.statusCode != 200) {
        resBodyMap = resBodyMap as Map<String, dynamic>;
        return Left(AppFailure(resBodyMap['detail']));
      }
      resBodyMap = resBodyMap as List;

      List<SongModel> songs = [];
      for (final map in resBodyMap) {
        songs.add(SongModel.fromMap(map));
      }
      return Right(songs);
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }
}
