import 'package:cached_network_image/cached_network_image.dart';
import 'package:melodix/core/providers/current_user_notifier.dart';
import 'package:melodix/core/theme/app_pallete.dart';
import 'package:melodix/core/utils.dart';
import 'package:melodix/core/widgets/loader.dart';
import 'package:melodix/features/home/models/follow_user_model.dart';
import 'package:melodix/features/home/view/pages/artist_profile_page.dart';
import 'package:melodix/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

enum FollowListTab { followers, following }

class FollowListPage extends ConsumerStatefulWidget {
  final String artistId;
  final String artistName;
  final FollowListTab initialTab;

  const FollowListPage({
    super.key,
    required this.artistId,
    required this.artistName,
    this.initialTab = FollowListTab.followers,
  });

  @override
  ConsumerState<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends ConsumerState<FollowListPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == FollowListTab.followers ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.artistName, style: const TextStyle(fontSize: 16)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Pallete.gradient2,
          labelColor: Pallete.whiteColor,
          unselectedLabelColor: Pallete.subtitleText,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [Tab(text: 'Followers'), Tab(text: 'Following')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FollowUserList(
            provider: getFollowersProvider(widget.artistId),
            emptyMessage: 'No followers yet',
          ),
          _FollowUserList(
            provider: getFollowingProvider(widget.artistId),
            emptyMessage: 'Not following anyone yet',
          ),
        ],
      ),
    );
  }
}

class _FollowUserList extends ConsumerWidget {
  final ProviderListenable<AsyncValue<List<FollowUserModel>>> provider;
  final String emptyMessage;

  const _FollowUserList({required this.provider, required this.emptyMessage});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(provider)
        .when(
          data: (users) {
            if (users.isEmpty) {
              return Center(
                child: Text(emptyMessage, style: const TextStyle(color: Pallete.subtitleText)),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: users.length,
              itemBuilder: (context, index) => _FollowUserTile(user: users[index]),
            );
          },
          error: (error, st) => Center(child: Text(error.toString())),
          loading: () => const Loader(),
        );
  }
}

class _FollowUserTile extends ConsumerStatefulWidget {
  final FollowUserModel user;

  const _FollowUserTile({required this.user});

  @override
  ConsumerState<_FollowUserTile> createState() => _FollowUserTileState();
}

class _FollowUserTileState extends ConsumerState<_FollowUserTile> {
  bool _isToggling = false;

  Future<void> _toggleFollow() async {
    if (_isToggling) return;
    setState(() => _isToggling = true);

    final res = await ref.read(homeViewModelProvider.notifier).toggleFollow(widget.user.id);

    if (!mounted) return;
    setState(() => _isToggling = false);

    switch (res) {
      case Left(value: final failure):
        showSnackBar(context, failure.message);
      case Right():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final currentUserId = ref.watch(currentUserProvider)?.id;
    final isSelf = user.id == currentUserId;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ArtistProfilePage(artistId: user.id, artistName: user.name),
          ),
        );
      },
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: Pallete.cardColor,
        backgroundImage: (user.avatar_url != null && user.avatar_url!.isNotEmpty)
            ? CachedNetworkImageProvider(user.avatar_url!)
            : null,
        child: (user.avatar_url == null || user.avatar_url!.isEmpty)
            ? const Icon(CupertinoIcons.person_fill, size: 20, color: Pallete.subtitleText)
            : null,
      ),
      title: Text(
        user.name,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isSelf
          ? null
          : SizedBox(
              height: 34,
              child: OutlinedButton(
                onPressed: _isToggling ? null : _toggleFollow,
                style: OutlinedButton.styleFrom(
                  backgroundColor: user.is_following ? Pallete.transparentColor : Pallete.gradient2,
                  foregroundColor: user.is_following ? Pallete.whiteColor : Pallete.backgroundColor,
                  side: BorderSide(
                    color: user.is_following ? Pallete.borderColor : Pallete.gradient2,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: const StadiumBorder(),
                ),
                child: _isToggling
                    ? const SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        user.is_following ? 'Following' : 'Follow',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
    );
  }
}
