import 'package:cached_network_image/cached_network_image.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/view/pages/artist_profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _ArtistInfo {
  final String? avatarUrl;
  final String? ownerId;

  _ArtistInfo({this.avatarUrl, this.ownerId});
}

/// name.
class ArtistsSection extends ConsumerWidget {
  final List<SongModel> songs;

  const ArtistsSection({super.key, required this.songs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistInfo = <String, _ArtistInfo>{};
    for (final song in songs) {
      artistInfo.putIfAbsent(
        song.artist,
        () => _ArtistInfo(
          avatarUrl: (song.artist_avatar_url != null && song.artist_avatar_url!.isNotEmpty)
              ? song.artist_avatar_url
              : null,
          ownerId: song.owner_id,
        ),
      );
    }
    final artists = artistInfo.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Artists', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: artists.length,
            itemBuilder: (context, index) {
              final artist = artists[index];
              final info = artistInfo[artist]!;
              return GestureDetector(
                onTap: info.ownerId == null
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ArtistProfilePage(artistId: info.ownerId!, artistName: artist),
                          ),
                        );
                      },
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 5),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Pallete.borderColor,
                        backgroundImage: info.avatarUrl != null
                            ? CachedNetworkImageProvider(info.avatarUrl!)
                            : null,
                        child: info.avatarUrl == null
                            ? const Icon(
                                CupertinoIcons.person_fill,
                                size: 40,
                                color: Pallete.subtitleText,
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 90,
                        child: Text(
                          artist,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
