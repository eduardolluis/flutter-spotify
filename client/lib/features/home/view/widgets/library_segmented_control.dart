import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melodix/core/theme/app_pallete.dart';

enum LibrarySegment { songs, playlists }

/// Pill-style switch between the favorite songs view and the playlists view,
/// with a contextual "add" action that only appears while browsing playlists.
class LibrarySegmentedControl extends StatelessWidget {
  final LibrarySegment segment;
  final ValueChanged<LibrarySegment> onChanged;
  final VoidCallback onAddPlaylist;

  const LibrarySegmentedControl({
    super.key,
    required this.segment,
    required this.onChanged,
    required this.onAddPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Pallete.borderColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _SegmentButton(
                    label: 'Songs',
                    icon: CupertinoIcons.heart_fill,
                    selected: segment == LibrarySegment.songs,
                    onTap: () => onChanged(LibrarySegment.songs),
                  ),
                ),
                Expanded(
                  child: _SegmentButton(
                    label: 'Playlists',
                    icon: CupertinoIcons.music_note_list,
                    selected: segment == LibrarySegment.playlists,
                    onTap: () => onChanged(LibrarySegment.playlists),
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: segment == LibrarySegment.playlists
              ? Padding(
                  key: const ValueKey('add-playlist'),
                  padding: const EdgeInsets.only(left: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onAddPlaylist,
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Pallete.gradient2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        CupertinoIcons.add,
                        color: Pallete.backgroundColor,
                      ),
                    ),
                  ),
                )
              : const SizedBox(key: ValueKey('no-add'), width: 0),
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? Pallete.cardColor : Pallete.transparentColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Pallete.transparentColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: selected ? Pallete.whiteColor : Pallete.subtitleText,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: selected ? Pallete.whiteColor : Pallete.subtitleText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
