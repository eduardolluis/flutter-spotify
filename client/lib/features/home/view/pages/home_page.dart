import 'package:client/core/theme/app_pallete.dart';
import 'package:client/features/home/view/pages/library_page.dart';
import 'package:client/features/home/view/pages/profile_page.dart';
import 'package:client/features/home/view/pages/search_page.dart';
import 'package:client/features/home/view/pages/songs_page.dart';
import 'package:client/features/home/view/widgets/music_slab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int selectedIndex = 0;
  final pages = const [SongsPage(), SearchPage(), LibraryPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Pallete.backgroundColor,
      body: Stack(
        children: [
          const Positioned.fill(child: _BrandBackground()),
          Positioned.fill(child: pages[selectedIndex]),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                    child: MusicSlab(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Pallete.backgroundColor,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (value) => setState(() => selectedIndex = value),
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              selectedIndex == 0
                  ? 'assets/images/home_filled.png'
                  : 'assets/images/home_unfilled.png',
              color: selectedIndex == 0 ? Pallete.whiteColor : Pallete.inactiveBottomBarItemColor,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.search,
              color: selectedIndex == 1 ? Pallete.whiteColor : Pallete.inactiveBottomBarItemColor,
            ),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/library.png',
              color: selectedIndex == 2 ? Pallete.whiteColor : Pallete.inactiveBottomBarItemColor,
            ),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              selectedIndex == 3 ? CupertinoIcons.person_fill : CupertinoIcons.person,
              color: selectedIndex == 3 ? Pallete.whiteColor : Pallete.inactiveBottomBarItemColor,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _BrandBackground extends StatelessWidget {
  const _BrandBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Pallete.backgroundColor),
        // blob difuminado arriba a la derecha, muy sutil
        Positioned(
          top: -80,
          right: -60,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Pallete.gradient1.withOpacity(0.18), Pallete.gradient1.withOpacity(0.0)],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -80,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Pallete.gradient3.withOpacity(0.14), Pallete.gradient3.withOpacity(0.0)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
