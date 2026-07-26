import 'package:client/core/theme/app_pallete.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmptyLibraryState extends StatelessWidget {
  final VoidCallback onUpload;

  const EmptyLibraryState({super.key, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.heart, size: 56, color: Pallete.subtitleText),
            const SizedBox(height: 16),
            const Text(
              "Your library is empty",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Mark songs as favorites or upload your own to see them here.",
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
              label: const Text("Upload Song"),
            ),
          ],
        ),
      ),
    );
  }
}
