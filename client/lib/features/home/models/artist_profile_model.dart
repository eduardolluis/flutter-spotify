import 'dart:convert';

// ignore_for_file: non_constant_identifier_names

import 'package:melodix/features/home/models/song_model.dart';

class ArtistProfileModel {
  final String id;
  final String name;
  final String? avatar_url;
  final int followers_count;
  final int following_count;
  final bool is_following;
  final List<SongModel> songs;

  ArtistProfileModel({
    required this.id,
    required this.name,
    this.avatar_url,
    required this.followers_count,
    required this.following_count,
    required this.is_following,
    required this.songs,
  });

  ArtistProfileModel copyWith({
    String? id,
    String? name,
    String? avatar_url,
    int? followers_count,
    int? following_count,
    bool? is_following,
    List<SongModel>? songs,
  }) {
    return ArtistProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar_url: avatar_url ?? this.avatar_url,
      followers_count: followers_count ?? this.followers_count,
      following_count: following_count ?? this.following_count,
      is_following: is_following ?? this.is_following,
      songs: songs ?? this.songs,
    );
  }

  factory ArtistProfileModel.fromMap(Map<String, dynamic> map) {
    return ArtistProfileModel(
      id: map['id'] ?? "",
      name: map['name'] ?? "",
      avatar_url: map['avatar_url'],
      followers_count: map['followers_count'] ?? 0,
      following_count: map['following_count'] ?? 0,
      is_following: map['is_following'] ?? false,
      songs: map['songs'] == null
          ? []
          : List<SongModel>.from(
              (map['songs'] as List<dynamic>).map<SongModel>(
                (x) => SongModel.fromMap(Map<String, dynamic>.from(x as Map)),
              ),
            ),
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'avatar_url': avatar_url,
      'followers_count': followers_count,
      'following_count': following_count,
      'is_following': is_following,
      'songs': songs.map((x) => x.toMap()).toList(),
    };
  }

  factory ArtistProfileModel.fromJson(String source) =>
      ArtistProfileModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
