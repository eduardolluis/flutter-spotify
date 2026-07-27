// ignore_for_file: non_constant_identifier_names, public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:melodix/features/home/models/fav_song_model.dart';
import 'package:collection/collection.dart';

class UserModel {
  final String name;
  final String email;
  final String id;
  final String token;
  final String? avatar_url;
  final List<FavSongModel> favorites;

  UserModel({
    required this.name,
    required this.email,
    required this.id,
    required this.token,
    this.avatar_url,
    required this.favorites,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? id,
    String? token,
    String? avatar_url,
    List<FavSongModel>? favorites,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      id: id ?? this.id,
      token: token ?? this.token,
      avatar_url: avatar_url ?? this.avatar_url,
      favorites: favorites ?? this.favorites,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'id': id,
      'token': token,
      'avatar_url': avatar_url,
      'favorites': favorites.map((x) => x.toMap()).toList(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? "",
      email: map['email'] ?? "",
      id: map['id'] ?? "",
      token: map['token'] ?? "",
      avatar_url: map['avatar_url'],
      // 🎯 CORREGIDO: Manejo ultra-seguro de nulos y casteo de mapas
      favorites: map['favorites'] == null
          ? []
          : List<FavSongModel>.from(
              (map['favorites'] as List<dynamic>).map<FavSongModel>(
                (x) => FavSongModel.fromMap(Map<String, dynamic>.from(x as Map)),
              ),
            ),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, id: $id, token: $token, avatar_url: $avatar_url, favorites: $favorites)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.name == name &&
        other.email == email &&
        other.id == id &&
        other.token == token &&
        other.avatar_url == avatar_url &&
        listEquals(other.favorites, favorites);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        email.hashCode ^
        id.hashCode ^
        token.hashCode ^
        avatar_url.hashCode ^
        favorites.hashCode;
  }
}
