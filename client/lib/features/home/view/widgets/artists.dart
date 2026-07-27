import 'package:cached_network_image/cached_network_image.dart';
import 'package:client/core/providers/current_song_notifier.dart';
import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/home/models/song_model.dart';
import 'package:client/features/home/view/pages/search_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// name.
class ArtistsSection extends ConsumerWidget {
  final List<SongModel> songs;

  const ArtistsSection({super.key, required this.songs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artistAvatars = <String, String?>{};
    for (final song in songs) {
      artistAvatars.putIfAbsent(
        song.artist,
        () => (song.artist_avatar_url != null && song.artist_avatar_url!.isNotEmpty)
            ? song.artist_avatar_url
            : null,
      );
    }
    final artists = artistAvatars.keys.toList();

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
              return GestureDetector(
                onTap: () {
                  ref.read(searchQueryProvider.notifier).state = artist;
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (context) => const SearchPage()));
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0, right: 5),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Pallete.borderColor,
                        backgroundImage: artistAvatars[artist] != null
                            ? CachedNetworkImageProvider(artistAvatars[artist]!)
                            : null,
                        child: artistAvatars[artist] == null
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
