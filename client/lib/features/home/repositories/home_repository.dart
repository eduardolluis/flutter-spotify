import 'dart:convert';
import 'dart:io';

import 'package:client/core/constants/server_constants.dart';
import 'package:http/http.dart' as http;

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
        http.MultipartRequest(
            'POST',
            Uri.parse('${ServerConstants.serverURL}/song/upload'),
          )
          ..headers['x-auth-token'] = token
          ..fields.addAll({
            'artist': artist,
            'song_name': songName,
            'hex_code': hexCode,
          })
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
}
