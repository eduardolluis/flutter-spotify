// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(playlists)
final playlistsProvider = PlaylistsProvider._();

final class PlaylistsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PlaylistModel>>,
          List<PlaylistModel>,
          FutureOr<List<PlaylistModel>>
        >
    with
        $FutureModifier<List<PlaylistModel>>,
        $FutureProvider<List<PlaylistModel>> {
  PlaylistsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'playlistsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$playlistsHash();

  @$internal
  @override
  $FutureProviderElement<List<PlaylistModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PlaylistModel>> create(Ref ref) {
    return playlists(ref);
  }
}

String _$playlistsHash() => r'90ea39bd4bd7c89bb8d683535606a816e375d42d';

@ProviderFor(playlistDetail)
final playlistDetailProvider = PlaylistDetailFamily._();

final class PlaylistDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<PlaylistModel>,
          PlaylistModel,
          FutureOr<PlaylistModel>
        >
    with $FutureModifier<PlaylistModel>, $FutureProvider<PlaylistModel> {
  PlaylistDetailProvider._({
    required PlaylistDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'playlistDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$playlistDetailHash();

  @override
  String toString() {
    return r'playlistDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PlaylistModel> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PlaylistModel> create(Ref ref) {
    final argument = this.argument as String;
    return playlistDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlaylistDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$playlistDetailHash() => r'73e0a8b8e598cc464ccfb0819ca158f6d1adf356';

final class PlaylistDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PlaylistModel>, String> {
  PlaylistDetailFamily._()
    : super(
        retry: null,
        name: r'playlistDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlaylistDetailProvider call(String playlistId) =>
      PlaylistDetailProvider._(argument: playlistId, from: this);

  @override
  String toString() => r'playlistDetailProvider';
}
