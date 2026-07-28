import 'package:melodix/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

/// Single source of truth for song genres so the upload screen and the
/// search screen always agree on the same list (and songs uploaded with a
/// given genre are actually filterable from search).
class Genre {
  final String label;
  final IconData icon;
  final Color color;

  const Genre({required this.label, required this.icon, required this.color});
}

const List<Genre> kGenres = [
  Genre(label: 'Pop', icon: Icons.star_rounded, color: Pallete.gradient2),
  Genre(label: 'Hip-Hop', icon: Icons.graphic_eq_rounded, color: Pallete.gradient1),
  Genre(label: 'Rock', icon: Icons.bolt_rounded, color: Pallete.gradient3),
  Genre(label: 'R&B', icon: Icons.favorite_rounded, color: Pallete.gradient2),
  Genre(label: 'Electronic', icon: Icons.blur_on_rounded, color: Pallete.gradient1),
  Genre(label: 'Chill', icon: Icons.spa_rounded, color: Pallete.gradient3),
  Genre(label: 'Jazz', icon: Icons.piano_rounded, color: Pallete.gradient2),
  Genre(label: 'Reggaeton', icon: Icons.whatshot_rounded, color: Pallete.gradient1),
  Genre(label: 'Classical', icon: Icons.theater_comedy_rounded, color: Pallete.gradient3),
  Genre(label: 'Other', icon: Icons.music_note_rounded, color: Pallete.subtitleText),
];

Genre genreByLabel(String? label) {
  return kGenres.firstWhere(
    (g) => g.label.toLowerCase() == (label ?? '').toLowerCase(),
    orElse: () => kGenres.last,
  );
}
