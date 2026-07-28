import 'dart:convert';

// ignore_for_file: non_constant_identifier_names

class SongModel {
  final String id;
  final String song_name;
  final String artist;
  final String thumbnail_url;
  final String song_url;
  final String hex_code;
  final String? genre;
  final String? owner_id;
  final String? artist_avatar_url;
  SongModel({
    required this.id,
    required this.song_name,
    required this.artist,
    required this.thumbnail_url,
    required this.song_url,
    required this.hex_code,
    this.genre,
    this.owner_id,
    this.artist_avatar_url,
  });

  SongModel copyWith({
    String? id,
    String? song_name,
    String? artist,
    String? thumbnail_url,
    String? song_url,
    String? hex_code,
    String? genre,
    String? owner_id,
    String? artist_avatar_url,
  }) {
    return SongModel(
      id: id ?? this.id,
      song_name: song_name ?? this.song_name,
      artist: artist ?? this.artist,
      thumbnail_url: thumbnail_url ?? this.thumbnail_url,
      song_url: song_url ?? this.song_url,
      hex_code: hex_code ?? this.hex_code,
      genre: genre ?? this.genre,
      owner_id: owner_id ?? this.owner_id,
      artist_avatar_url: artist_avatar_url ?? this.artist_avatar_url,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'song_name': song_name,
      'artist': artist,
      'thumbnail_url': thumbnail_url,
      'song_url': song_url,
      'hex_code': hex_code,
      'genre': genre,
      'owner_id': owner_id,
      'artist_avatar_url': artist_avatar_url,
    };
  }

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['id'] ?? "",
      song_name: map['song_name'] ?? "",
      artist: map['artist'] ?? "",
      thumbnail_url: map['thumbnail_url'] ?? "",
      song_url: map['song_url'] ?? "",
      hex_code: map['hex_code'] ?? "",
      genre: map['genre'],
      owner_id: map['owner_id'],
      artist_avatar_url: map['artist_avatar_url'],
    );
  }

  String toJson() => json.encode(toMap());

  factory SongModel.fromJson(String source) =>
      SongModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SongModel(id: $id, song_name: $song_name, artist: $artist, thumbnail_url: $thumbnail_url, song_url: $song_url, hex_code: $hex_code, genre: $genre, owner_id: $owner_id, artist_avatar_url: $artist_avatar_url)';
  }

  @override
  bool operator ==(covariant SongModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.song_name == song_name &&
        other.artist == artist &&
        other.thumbnail_url == thumbnail_url &&
        other.song_url == song_url &&
        other.hex_code == hex_code &&
        other.genre == genre &&
        other.owner_id == owner_id &&
        other.artist_avatar_url == artist_avatar_url;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        song_name.hashCode ^
        artist.hashCode ^
        thumbnail_url.hashCode ^
        song_url.hashCode ^
        hex_code.hashCode ^
        genre.hashCode ^
        owner_id.hashCode ^
        artist_avatar_url.hashCode;
  }
}
