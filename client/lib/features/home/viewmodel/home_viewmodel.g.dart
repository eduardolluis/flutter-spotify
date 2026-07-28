// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(getAllSongs)
final getAllSongsProvider = GetAllSongsProvider._();

final class GetAllSongsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SongModel>>,
          List<SongModel>,
          FutureOr<List<SongModel>>
        >
    with $FutureModifier<List<SongModel>>, $FutureProvider<List<SongModel>> {
  GetAllSongsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getAllSongsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getAllSongsHash();

  @$internal
  @override
  $FutureProviderElement<List<SongModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SongModel>> create(Ref ref) {
    return getAllSongs(ref);
  }
}

String _$getAllSongsHash() => r'd6bdb875ad128521e8e6447de8749f93355a0ce6';

@ProviderFor(getFavSongs)
final getFavSongsProvider = GetFavSongsProvider._();

final class GetFavSongsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SongModel>>,
          List<SongModel>,
          FutureOr<List<SongModel>>
        >
    with $FutureModifier<List<SongModel>>, $FutureProvider<List<SongModel>> {
  GetFavSongsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getFavSongsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getFavSongsHash();

  @$internal
  @override
  $FutureProviderElement<List<SongModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SongModel>> create(Ref ref) {
    return getFavSongs(ref);
  }
}

String _$getFavSongsHash() => r'7a2fc0e9d8b5f6852cb9f1412053c55556888a2b';

@ProviderFor(getArtistProfile)
final getArtistProfileProvider = GetArtistProfileFamily._();

final class GetArtistProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<ArtistProfileModel>,
          ArtistProfileModel,
          FutureOr<ArtistProfileModel>
        >
    with
        $FutureModifier<ArtistProfileModel>,
        $FutureProvider<ArtistProfileModel> {
  GetArtistProfileProvider._({
    required GetArtistProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'getArtistProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getArtistProfileHash();

  @override
  String toString() {
    return r'getArtistProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ArtistProfileModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ArtistProfileModel> create(Ref ref) {
    final argument = this.argument as String;
    return getArtistProfile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GetArtistProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getArtistProfileHash() => r'884b8c362b1cf71dcb0c6917d4ba3ab5895314d0';

final class GetArtistProfileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ArtistProfileModel>, String> {
  GetArtistProfileFamily._()
    : super(
        retry: null,
        name: r'getArtistProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GetArtistProfileProvider call(String artistId) =>
      GetArtistProfileProvider._(argument: artistId, from: this);

  @override
  String toString() => r'getArtistProfileProvider';
}

@ProviderFor(getFollowers)
final getFollowersProvider = GetFollowersFamily._();

final class GetFollowersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FollowUserModel>>,
          List<FollowUserModel>,
          FutureOr<List<FollowUserModel>>
        >
    with
        $FutureModifier<List<FollowUserModel>>,
        $FutureProvider<List<FollowUserModel>> {
  GetFollowersProvider._({
    required GetFollowersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'getFollowersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getFollowersHash();

  @override
  String toString() {
    return r'getFollowersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<FollowUserModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FollowUserModel>> create(Ref ref) {
    final argument = this.argument as String;
    return getFollowers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GetFollowersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getFollowersHash() => r'a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0';

final class GetFollowersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<FollowUserModel>>, String> {
  GetFollowersFamily._()
    : super(
        retry: null,
        name: r'getFollowersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GetFollowersProvider call(String artistId) =>
      GetFollowersProvider._(argument: artistId, from: this);

  @override
  String toString() => r'getFollowersProvider';
}

@ProviderFor(getFollowing)
final getFollowingProvider = GetFollowingFamily._();

final class GetFollowingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FollowUserModel>>,
          List<FollowUserModel>,
          FutureOr<List<FollowUserModel>>
        >
    with
        $FutureModifier<List<FollowUserModel>>,
        $FutureProvider<List<FollowUserModel>> {
  GetFollowingProvider._({
    required GetFollowingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'getFollowingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getFollowingHash();

  @override
  String toString() {
    return r'getFollowingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<FollowUserModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FollowUserModel>> create(Ref ref) {
    final argument = this.argument as String;
    return getFollowing(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GetFollowingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getFollowingHash() => r'b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1';

final class GetFollowingFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<FollowUserModel>>, String> {
  GetFollowingFamily._()
    : super(
        retry: null,
        name: r'getFollowingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GetFollowingProvider call(String artistId) =>
      GetFollowingProvider._(argument: artistId, from: this);

  @override
  String toString() => r'getFollowingProvider';
}

@ProviderFor(HomeViewModel)
final homeViewModelProvider = HomeViewModelProvider._();

final class HomeViewModelProvider
    extends $AsyncNotifierProvider<HomeViewModel, dynamic> {
  HomeViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeViewModelHash();

  @$internal
  @override
  HomeViewModel create() => HomeViewModel();
}

String _$homeViewModelHash() => r'03a232f75b3a3a0bbe5a17c672aec450e34c4279';

abstract class _$HomeViewModel extends $AsyncNotifier<dynamic> {
  FutureOr<dynamic> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<dynamic>, dynamic>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<dynamic>, dynamic>,
              AsyncValue<dynamic>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
