// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_song_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IsPlaying)
final isPlayingProvider = IsPlayingProvider._();

final class IsPlayingProvider extends $NotifierProvider<IsPlaying, bool> {
  IsPlayingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isPlayingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isPlayingHash();

  @$internal
  @override
  IsPlaying create() => IsPlaying();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isPlayingHash() => r'72a2dad7d3e5e4c5823042f8803e30d84d4a4343';

abstract class _$IsPlaying extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(Shuffle)
final shuffleProvider = ShuffleProvider._();

final class ShuffleProvider extends $NotifierProvider<Shuffle, bool> {
  ShuffleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shuffleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shuffleHash();

  @$internal
  @override
  Shuffle create() => Shuffle();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$shuffleHash() => r'd0074995de632559b630ae72b3e87352d9848580';

abstract class _$Shuffle extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(Repeat)
final repeatProvider = RepeatProvider._();

final class RepeatProvider extends $NotifierProvider<Repeat, bool> {
  RepeatProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'repeatProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$repeatHash();

  @$internal
  @override
  Repeat create() => Repeat();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$repeatHash() => r'f5c5f7009595e6e8774e324283a90ebdc70da17f';

abstract class _$Repeat extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SearchQuery)
final searchQueryProvider = SearchQueryProvider._();

final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'c20c8b67cdf9a8c8820d422de83c580e88655dcd';

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(LibrarySearchQuery)
final librarySearchQueryProvider = LibrarySearchQueryProvider._();

final class LibrarySearchQueryProvider
    extends $NotifierProvider<LibrarySearchQuery, String> {
  LibrarySearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'librarySearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$librarySearchQueryHash();

  @$internal
  @override
  LibrarySearchQuery create() => LibrarySearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$librarySearchQueryHash() =>
    r'409814798eb4ede9cf088f8c7c8078665599ad20';

abstract class _$LibrarySearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(CurrentSongNotifier)
final currentSongProvider = CurrentSongNotifierProvider._();

final class CurrentSongNotifierProvider
    extends $NotifierProvider<CurrentSongNotifier, SongModel?> {
  CurrentSongNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSongProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentSongNotifierHash();

  @$internal
  @override
  CurrentSongNotifier create() => CurrentSongNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SongModel? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SongModel?>(value),
    );
  }
}

String _$currentSongNotifierHash() =>
    r'949042cf797c33e90d6751f86303cfaa1826c03f';

abstract class _$CurrentSongNotifier extends $Notifier<SongModel?> {
  SongModel? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SongModel?, SongModel?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SongModel?, SongModel?>,
              SongModel?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
