import 'package:cached_network_image/cached_network_image.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/features/home/models/song_model.dart';
import 'package:melodix/features/home/view/pages/artist_profile_page.dart';
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
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Artists',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              height: 1.2,
            ),
          ),
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
                  padding: EdgeInsets.only(right: index == artists.length - 1 ? 0 : 18),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Pallete.borderColor.withValues(alpha: 0.7),
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: Pallete.borderColor,
                          backgroundImage: info.avatarUrl != null
                              ? CachedNetworkImageProvider(info.avatarUrl!)
                              : null,
                          child: info.avatarUrl == null
                              ? const Icon(
                                  CupertinoIcons.person_fill,
                                  size: 38,
                                  color: Pallete.subtitleText,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 88,
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
