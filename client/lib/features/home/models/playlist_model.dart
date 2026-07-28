import 'dart:convert';

// ignore_for_file: non_constant_identifier_names

import 'package:melodix/features/home/models/song_model.dart';

class PlaylistModel {
  final String id;
  final String name;
  final String owner_id;
  final int song_count;
  final String? cover_thumbnail_url;
  final List<SongModel>? songs;

  PlaylistModel({
    required this.id,
    required this.name,
    required this.owner_id,
    required this.song_count,
    this.cover_thumbnail_url,
    this.songs,
  });

  PlaylistModel copyWith({
    String? id,
    String? name,
    String? owner_id,
    int? song_count,
    String? cover_thumbnail_url,
    List<SongModel>? songs,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      owner_id: owner_id ?? this.owner_id,
      song_count: song_count ?? this.song_count,
      cover_thumbnail_url: cover_thumbnail_url ?? this.cover_thumbnail_url,
      songs: songs ?? this.songs,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'owner_id': owner_id,
      'song_count': song_count,
      'cover_thumbnail_url': cover_thumbnail_url,
      'songs': songs?.map((x) => x.toMap()).toList(),
    };
  }

  factory PlaylistModel.fromMap(Map<String, dynamic> map) {
    return PlaylistModel(
      id: map['id'] ?? "",
      name: map['name'] ?? "",
      owner_id: map['owner_id'] ?? "",
      song_count: map['song_count'] ?? 0,
      cover_thumbnail_url: map['cover_thumbnail_url'],
      songs: map['songs'] == null
          ? null
          : List<SongModel>.from(
              (map['songs'] as List<dynamic>).map<SongModel>(
                (x) => SongModel.fromMap(Map<String, dynamic>.from(x as Map)),
              ),
            ),
    );
  }

  String toJson() => json.encode(toMap());

  factory PlaylistModel.fromJson(String source) =>
      PlaylistModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PlaylistModel(id: $id, name: $name, owner_id: $owner_id, song_count: $song_count, cover_thumbnail_url: $cover_thumbnail_url, songs: $songs)';
  }
}
