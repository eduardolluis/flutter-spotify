import 'dart:async';
import 'dart:io';
import 'package:client/core/failure/failure.dart';
import 'package:client/core/providers/current_user_notifier.dart';
import 'package:client/core/models/user_model.dart';
import 'package:client/features/auth/repositories/auth_local_repository.dart';
import 'package:client/features/auth/repositories/auth_remote_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_viewmodel.g.dart';

@Riverpod(keepAlive: true)
class AuthViewModel extends _$AuthViewModel {
  late AuthRemoteRepository _authRemoteRepository;
  late AuthLocalRepository _authLocalRepository;
  late CurrentUserNotifier _currentUserNotifier;

  @override
  FutureOr<UserModel?> build() {
    _authRemoteRepository = ref.watch(authRemoteRepositoryProvider);
    _authLocalRepository = ref.watch(authLocalRepositoryProvider);
    _currentUserNotifier = ref.read(currentUserProvider.notifier);
    return null;
  }

  Future<void> initSharedPreferences() async {
    await _authLocalRepository.init();
  }

  Future<void> signUpUser({
    required String name,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final res = await _authRemoteRepository.signUp(name: name, email: email, password: password);

    if (!ref.mounted) return;

    switch (res) {
      case Left(value: final failure):
        state = AsyncValue.error(failure.message, StackTrace.current);

      case Right(value: final user):
        _loginSuccess(user);
    }
  }

  Future<void> loginUser({required String email, required String password}) async {
    state = const AsyncValue.loading();

    final res = await _authRemoteRepository.logIn(email: email, password: password);

    if (!ref.mounted) return;

    switch (res) {
      case Left(value: final failure):
        state = AsyncValue.error(failure.message, StackTrace.current);

      case Right(value: final user):
        _loginSuccess(user);
    }
  }

  Future<void> loginWithGoogle() async {
    state = const AsyncValue.loading();

    final res = await _authRemoteRepository.loginWithGoogle();

    if (!ref.mounted) return;

    switch (res) {
      case Left(value: final failure):
        state = AsyncValue.error(failure.message, StackTrace.current);

      case Right(value: final user):
        _loginSuccess(user);
    }
  }

  AsyncValue<UserModel?> _loginSuccess(UserModel user) {
    _authLocalRepository.setToken(user.token);
    _currentUserNotifier.addUser(user);
    return state = AsyncValue.data(user);
  }

  Future<UserModel?> getData() async {
    state = const AsyncValue.loading();
    final token = _authLocalRepository.getToken();

    if (token != null) {
      final res = await _authRemoteRepository.getCurrentUserData(token);

      if (!ref.mounted) return null;

      switch (res) {
        case Left(value: final failure):
          state = AsyncValue.error(failure.message, StackTrace.current);

        case Right(value: final user):
          return _getDataSuccess(user).value;
      }
    } else {
      if (ref.mounted) {
        state = const AsyncValue.data(null);
      }
    }
    return null;
  }

  AsyncValue<UserModel?> _getDataSuccess(UserModel user) {
    _authLocalRepository.setToken(user.token);
    _currentUserNotifier.addUser(user);
    return state = AsyncValue.data(user);
  }

  Future<void> logout() async {
    await _authLocalRepository.removeToken();
    _currentUserNotifier.removeUser();
    state = const AsyncValue.data(null);
  }

  /// Sube la foto elegida y actualiza al usuario actual (así el avatar
  /// nuevo se refleja en toda la app, incluido el Home).
  Future<Either<AppFailure, UserModel>> updateAvatar(File avatar) async {
    final currentToken = _authLocalRepository.getToken();
    if (currentToken == null) {
      return Left(AppFailure('No estás autenticado.'));
    }

    state = const AsyncValue.loading();
    final res = await _authRemoteRepository.uploadAvatar(avatar: avatar, token: currentToken);

    if (!ref.mounted) return res;

    switch (res) {
      case Left(value: final failure):
        return Left(failure);
      case Right(value: final user):
        _currentUserNotifier.addUser(user);
        state = AsyncValue.data(user);
        return Right(user);
    }
  }
}
