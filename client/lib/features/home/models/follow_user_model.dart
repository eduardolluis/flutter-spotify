// ignore_for_file: non_constant_identifier_names

class FollowUserModel {
  final String id;
  final String name;
  final String? avatar_url;
  final bool is_following;
  final bool is_self;

  FollowUserModel({
    required this.id,
    required this.name,
    this.avatar_url,
    required this.is_following,
    required this.is_self,
  });

  FollowUserModel copyWith({
    String? id,
    String? name,
    String? avatar_url,
    bool? is_following,
    bool? is_self,
  }) {
    return FollowUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar_url: avatar_url ?? this.avatar_url,
      is_following: is_following ?? this.is_following,
      is_self: is_self ?? this.is_self,
    );
  }

  factory FollowUserModel.fromMap(Map<String, dynamic> map) {
    return FollowUserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      avatar_url: map['avatar_url'],
      is_following: map['is_following'] ?? false,
      is_self: map['is_self'] ?? false,
    );
  }
}
