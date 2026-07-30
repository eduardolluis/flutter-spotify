import 'dart:convert';
import 'dart:io';
import 'package:melodix/core/constants/server_constants.dart';
import 'package:melodix/core/failure/failure.dart';
import 'package:melodix/core/models/user_model.dart';
import 'package:melodix/services/google_auth_service.dart';
import 'package:fpdart/fpdart.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_remote_repository.g.dart';

@riverpod
AuthRemoteRepository authRemoteRepository(Ref ref) {
  return AuthRemoteRepository();
}

class AuthRemoteRepository {
  Future<Either<AppFailure, UserModel>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ServerConstants.serverURL}/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode != 201) {
        try {
          final errorMap = jsonDecode(response.body) as Map<String, dynamic>;
          return Left(AppFailure(errorMap['detail'].toString()));
        } catch (_) {
          return Left(AppFailure('Server Error: ${response.statusCode}'));
        }
      }
      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;
      return Right(UserModel.fromMap(resBodyMap['user']).copyWith(token: resBodyMap['token']));
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ServerConstants.serverURL}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode != 200) {
        try {
          final errorMap = jsonDecode(response.body) as Map<String, dynamic>;
          return Left(AppFailure(errorMap['detail'].toString()));
        } catch (_) {
          return Left(AppFailure('Server Error: ${response.statusCode}'));
        }
      }

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;
      return Right(UserModel.fromMap(resBodyMap['user']).copyWith(token: resBodyMap['token']));
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> loginWithGoogle() async {
    try {
      final idToken = await GoogleAuthHelper().getIdToken();

      if (idToken == null) {
        return Left(AppFailure('Sign-in cancelled'));
      }

      final response = await http.post(
        Uri.parse('${ServerConstants.serverURL}/auth/google-mobile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_token': idToken}),
      );

      if (response.statusCode != 200) {
        try {
          final errorMap = jsonDecode(response.body) as Map<String, dynamic>;
          return Left(AppFailure(errorMap['detail'] ?? 'Google authentication error'));
        } catch (_) {
          return Left(AppFailure('Error del servidor: ${response.statusCode}'));
        }
      }

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;
      return Right(UserModel.fromMap(resBodyMap['user']).copyWith(token: resBodyMap['token']));
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> getCurrentUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ServerConstants.serverURL}/auth/'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );
      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(AppFailure(resBodyMap['detail'].toString()));
      }
      return Right(UserModel.fromMap(resBodyMap).copyWith(token: token));
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> updateProfile({
    required String name,
    required String email,
    required String token,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ServerConstants.serverURL}/user/'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
        body: jsonEncode({'name': name, 'email': email}),
      );

      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(AppFailure(resBodyMap['detail'].toString()));
      }
      return Right(UserModel.fromMap(resBodyMap).copyWith(token: token));
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }

  Future<Either<AppFailure, UserModel>> uploadAvatar({
    required File avatar,
    required String token,
  }) async {
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse('${ServerConstants.serverURL}/user/avatar'))
            ..headers['x-auth-token'] = token
            ..files.add(await http.MultipartFile.fromPath('avatar', avatar.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final resBodyMap = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        return Left(AppFailure(resBodyMap['detail'].toString()));
      }
      return Right(UserModel.fromMap(resBodyMap).copyWith(token: token));
    } catch (e) {
      return Left(AppFailure(e.toString()));
    }
  }
}
