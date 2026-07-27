import 'package:melodix/core/theme/app_pallete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Friendly empty state shown when the user has no songs yet, instead of
/// leaving "Latest today" with nothing under it.
class EmptySongsState extends StatelessWidget {
  final VoidCallback onUpload;

  const EmptySongsState({super.key, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        children: [
          const Icon(CupertinoIcons.music_note_2, size: 56, color: Pallete.subtitleText),
          const SizedBox(height: 16),
          const Text(
            "No songs yet",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            "Upload your first song to start building your library.",
            style: TextStyle(fontSize: 13, color: Pallete.subtitleText),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: Pallete.cardColor,
              foregroundColor: Pallete.whiteColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
            icon: const Icon(CupertinoIcons.add),
            label: const Text("Upload song"),
          ),
        ],
      ),
    );
  }
}
