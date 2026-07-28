import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/features/home/view/pages/library_page.dart';
import 'package:melodix/features/home/view/pages/my_songs_page.dart';
import 'package:melodix/features/home/view/pages/playlists_page.dart';
import 'package:melodix/features/home/view/pages/settings_page.dart';
import 'package:melodix/features/home/view/pages/upload_song_page.dart';
import 'package:melodix/features/home/view/widgets/vinyl_track_tile.dart';

/// The "Library" card on the Profile page — quick links to My Songs,
/// Upload, Favorites, Settings, and Playlists.
class ProfileLibraryMenu extends StatelessWidget {
  const ProfileLibraryMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Pallete.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          VinylTrackTile(
            index: '01',
            icon: CupertinoIcons.music_note_2,
            title: 'My Songs',
            subtitle: 'Manage uploads',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MySongsPage()));
            },
          ),
          const Divider(height: 1, color: Colors.white10),
          VinylTrackTile(
            index: '02',
            icon: CupertinoIcons.cloud_upload_fill,
            title: 'Upload',
            subtitle: 'Share music',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadSongPage()));
            },
          ),
          const Divider(height: 1, color: Colors.white10),
          VinylTrackTile(
            index: '03',
            icon: CupertinoIcons.heart_fill,
            title: 'Favorites',
            subtitle: 'Liked tracks',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(title: const Text('Favorites')),
                    body: const LibraryPage(),
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1, color: Colors.white10),
          VinylTrackTile(
            index: '04',
            icon: CupertinoIcons.gear_alt_fill,
            title: 'Settings',
            subtitle: 'Preferences',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
            },
          ),
          const Divider(height: 1, color: Colors.white10),
          VinylTrackTile(
            index: '05',
            icon: CupertinoIcons.music_note_list,
            title: 'Playlists',
            subtitle: 'Your custom mixes',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PlaylistsPage()));
            },
          ),
        ],
      ),
    );
  }
}
