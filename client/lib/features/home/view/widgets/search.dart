import 'package:client/core/theme/app_pallete.dart';
import 'package:flutter/cupertino.dart';

class SearchPlaceholder extends StatelessWidget {
  const SearchPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.search, size: 56, color: Pallete.subtitleText),
            const SizedBox(height: 16),
            const Text(
              'Search for songs, artists..',
              style: TextStyle(fontSize: 16, color: Pallete.subtitleText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
