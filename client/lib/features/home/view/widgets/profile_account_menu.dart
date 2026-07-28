import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/features/home/view/pages/edit_profile_page.dart';
import 'package:melodix/features/home/view/widgets/profile_action_tile.dart';

/// The "Account" section on the Profile page — edit profile and log out.
class ProfileAccountMenu extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileAccountMenu({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileActionTile(
          icon: CupertinoIcons.person_crop_circle_fill,
          iconColor: Pallete.gradient2,
          label: "Edit profile",
          subtitle: "Change your avatar and information",
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage()));
          },
        ),
        const SizedBox(height: 12),
        ProfileActionTile(
          icon: CupertinoIcons.square_arrow_right,
          iconColor: Colors.redAccent,
          label: "Log out",
          subtitle: "Sign out of Melodix",
          onTap: onLogout,
        ),
      ],
    );
  }
}
