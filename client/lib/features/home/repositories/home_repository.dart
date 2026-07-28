  import 'dart:convert';
  import 'dart:io';

  import 'package:melodix/core/constants/server_constants.dart';
  import 'package:melodix/core/failure/failure.dart';
  import 'package:melodix/features/home/models/artist_profile_model.dart';
  import 'package:melodix/features/home/models/follow_user_model.dart';
  import 'package:melodix/features/home/models/playlist_model.dart';
  import 'package:melodix/features/home/models/song_model.dart';
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
      required String genre,
      required String token,
    }) async {
      final request =
          http.MultipartRequest('POST', Uri.parse('${ServerConstants.serverURL}/song/upload'))
            ..headers['x-auth-token'] = token
            ..fields.addAll({
              'artist': artist,
              'song_name': songName,
              'hex_code': hexCode,
              'genre': genre,
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

    Future<Either<AppFailure, List<SongModel>>> getAllSongs({required String token}) async {
      try {
        final res = await http.get(
          Uri.parse('${ServerConstants.serverURL}/song/list'),
          headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        );

        if (res.statusCode != 200) {
          try {
            final errorMap = jsonDecode(res.body) as Map<String, dynamic>;
            return Left(AppFailure(errorMap['detail'] ?? 'Error loading songs'));
          } catch (_) {
            return Left(AppFailure('Server error: ${res.statusCode}'));
          }
        }

        final resBodyMap = jsonDecode(res.body) as List;
        List<SongModel> songs = [];
        for (final map in resBodyMap) {
          songs.add(SongModel.fromMap(map));
        }
        return Right(songs);
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

        if (res.statusCode != 200) {
          try {
            final errorMap = jsonDecode(res.body) as Map<String, dynamic>;
            return Left(AppFailure(errorMap['detail'] ?? 'Error loading favorites'));
          } catch (_) {
            return Left(AppFailure('Server error: ${res.statusCode}'));
          }
        }

        final resBodyMap = jsonDecode(res.body) as List;
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

    Future<Either<AppFailure, String>> deleteSong({
      required String token,
      required String songId,
    }) async {
      try {
        final res = await http.delete(
          Uri.parse('${ServerConstants.serverURL}/song/$songId'),
          headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        );
        final resBodyMap = jsonDecode(res.body) as Map<String, dynamic>;

        if (res.statusCode != 200) {
          return Left(AppFailure(resBodyMap['detail'].toString()));
        }
        return Right(resBodyMap['message'] ?? 'Song deleted successfully.');
      } catch (e) {
        return Left(AppFailure(e.toString()));
      }
    }

    Future<Either<AppFailure, ArtistProfileModel>> getArtistProfile({
      required String token,
      required String artistId,
    }) async {
      try {
        final res = await http.get(
          Uri.parse('${ServerConstants.serverURL}/user/$artistId'),
          headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        );

        final resBodyMap = jsonDecode(res.body) as Map<String, dynamic>;

        if (res.statusCode != 200) {
          return Left(AppFailure(resBodyMap['detail'] ?? 'Error loading artist profile'));
        }

        return Right(ArtistProfileModel.fromMap(resBodyMap));
      } catch (e) {
        return Left(AppFailure(e.toString()));
      }
    }

    Future<Either<AppFailure, Map<String, dynamic>>> followArtist({
      required String token,
      required String artistId,
    }) async {
      try {
        final res = await http.post(
          Uri.parse('${ServerConstants.serverURL}/user/$artistId/follow'),
          headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        );

        final resBodyMap = jsonDecode(res.body) as Map<String, dynamic>;

        if (res.statusCode != 200) {
          return Left(AppFailure(resBodyMap['detail'] ?? 'Error following artist'));
        }

        return Right(resBodyMap);
      } catch (e) {
        return Left(AppFailure(e.toString()));
      }
    }

    Future<Either<AppFailure, List<FollowUserModel>>> getFollowers({
      required String token,
      required String artistId,
    }) async {
      try {
        final res = await http.get(
          Uri.parse('${ServerConstants.serverURL}/user/$artistId/followers'),
          headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        );

        if (res.statusCode != 200) {
          try {
            final errorMap = jsonDecode(res.body) as Map<String, dynamic>;
            return Left(AppFailure(errorMap['detail'] ?? 'Error loading followers'));
          } catch (_) {
            return Left(AppFailure('Server error: ${res.statusCode}'));
          }
        }

        final resBodyList = jsonDecode(res.body) as List;
        return Right(resBodyList.map((e) => FollowUserModel.fromMap(e)).toList());
      } catch (e) {
        return Left(AppFailure(e.toString()));
      }
    }

    Future<Either<AppFailure, List<FollowUserModel>>> getFollowing({
      required String token,
      required String artistId,
    }) async {
      try {
        final res = await http.get(
          Uri.parse('${ServerConstants.serverURL}/user/$artistId/following'),
          headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        );

        if (res.statusCode != 200) {
          try {
            final errorMap = jsonDecode(res.body) as Map<String, dynamic>;
            return Left(AppFailure(errorMap['detail'] ?? 'Error loading following'));
          } catch (_) {
            return Left(AppFailure('Server error: ${res.statusCode}'));
          }
        }

        final resBodyList = jsonDecode(res.body) as List;
        return Right(resBodyList.map((e) => FollowUserModel.fromMap(e)).toList());
      } catch (e) {
        return Left(AppFailure(e.toString()));
      }
    }

    Future<Either<AppFailure, List<PlaylistModel>>> getPlaylists({required String token}) async {
      try {
        final res = await http.get(
          Uri.parse('${ServerConstants.serverURL}/playlist/'),
          headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        );

        if (res.statusCode != 200) {
          try {
            final errorMap = jsonDecode(res.body) as Map<String, dynamic>;
            return Left(AppFailure(errorMap['detail'] ?? 'Error loading playlists'));
          } catch (_) {
            return Left(AppFailure('Server error: ${res.statusCode}'));
          }
        }

        final resBodyList = jsonDecode(res.body) as List;
        return Right(resBodyList.map((e) => PlaylistModel.fromMap(e)).toList());
      } catch (e) {
        return Left(AppFailure(e.toString()));
      }
    }

    Future<Either<AppFailure, PlaylistModel>> getPlaylist({
      required String token,
      required String playlistId,
    }) async {
      try {
        final res = await http.get(
          Uri.parse('${ServerConstants.serverURL}/playlist/$playlistId'),
          headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        );

        final resBodyMap = jsonDecode(res.body) as Map<String, dynamic>;

        if (res.statusCode != 200) {
          return Left(AppFailure(resBodyMap['detail'] ?? 'Error loading playlist'));
        }
        return Right(PlaylistModel.fromMap(resBodyMap));
      } catch (e) {
        return Left(AppFailure(e.toString()));
      }
    }

    Future<Either<AppFailure, PlaylistModel>> createPlaylist({
      required String token,
      required String name,
    }) async {
      try {
        final res = await http.post(
          Uri.parse('${ServerConstants.serverURL}/playlist/'),
          headers: {'Content-Type': 'application/json', 'x-auth-token': token},
          body: jsonEncode({'name': name}),
        );

        final resBodyMap = jsonDecode(res.body) as Map<String, dynamic>;

        if (res.statusCode != 201) {
          return Left(AppFailure(resBodyMap['detail'] ?? 'Error creating playlist'));
        }
        return Right(PlaylistModel.fromMap(resBodyMap));
      } catch (e) {
        return Left(AppFailure(e.toString()));
      }
    }

    Future<Either<AppFailure, PlaylistModel>> addSongToPlaylist({
      required String token,
      required String playlistId,
      required String songId,
    }) async {
      try {
        final res = await http.post(
          Uri.parse('${ServerConstants.serverURL}/playlist/$playlistId/songs'),
          headers: {'Content-Type': 'application/json', 'x-auth-token': token},
          body: jsonEncode({'song_id': songId}),
        );

        final resBodyMap = jsonDecode(res.body) as Map<String, dynamic>;

        if (res.statusCode != 200) {
          return Left(AppFailure(resBodyMap['detail'] ?? 'Error adding song'));
        }
        return Right(PlaylistModel.fromMap(resBodyMap));
      } catch (e) {
        return Left(AppFailure(e.toString()));
      }
    }

    Future<Either<AppFailure, PlaylistModel>> removeSongFromPlaylist({
      required String token,
      required String playlistId,
      required String songId,
    }) async {
      try {
        final res = await http.delete(
          Uri.parse('${ServerConstants.serverURL}/playlist/$playlistId/songs/$songId'),
          headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        );

        final resBodyMap = jsonDecode(res.body) as Map<String, dynamic>;

        if (res.statusCode != 200) {
          return Left(AppFailure(resBodyMap['detail'] ?? 'Error removing song'));
        }
        return Right(PlaylistModel.fromMap(resBodyMap));
      } catch (e) {
        return Left(AppFailure(e.toString()));
      }
    }

    Future<Either<AppFailure, String>> deletePlaylist({
      required String token,
      required String playlistId,
    }) async {
      try {
        final res = await http.delete(
          Uri.parse('${ServerConstants.serverURL}/playlist/$playlistId'),
          headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        );

        final resBodyMap = jsonDecode(res.body) as Map<String, dynamic>;

        if (res.statusCode != 200) {
          return Left(AppFailure(resBodyMap['detail'] ?? 'Error deleting playlist'));
        }
        return Right(resBodyMap['message'] ?? 'Playlist deleted successfully.');
      } catch (e) {
        return Left(AppFailure(e.toString()));
      }
    }
  }
