import 'package:flutter/material.dart';
import 'package:goryon/screens/report.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api.dart';
import '../models.dart';
import '../viewmodels.dart';
import '../widgets/common_widgets.dart';
import 'newtwt.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future _fetchProfileFuture;
  Future _followFuture;
  Future _unFollowFuture;
  Future _muteFuture;

  @override
  void initState() {
    super.initState();
    _fetchProfileFuture = _fetchProfile().then((_) async {
      await context.read<ProfileViewModel>().refreshPost();
    });
  }

  Future _fetchProfile() async {
    await context.read<ProfileViewModel>().fetchProfile();
  }

  Future _follow(String nick, String url, BuildContext context) async {
    try {
      await context.read<AuthViewModel>().follow(nick, url);
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully followed $nick'),
        ),
      );
    } catch (e) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to follow $nick'),
        ),
      );
      rethrow;
    }
  }

  Future _unFollow(String nick, BuildContext context) async {
    try {
      await context.read<AuthViewModel>().unfollow(nick);
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully unfollowed $nick'),
        ),
      );
    } catch (e) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to unfollow $nick'),
        ),
      );
      rethrow;
    }
  }

  Future _mute(BuildContext context) async {
    try {
      await context.read<ProfileViewModel>().mute();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully muted user/feed'),
        ),
      );
    } catch (e) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mute user/feed'),
        ),
      );
      rethrow;
    }
  }

  Future _unmute(BuildContext context) async {
    try {
      await context.read<ProfileViewModel>().unmute();
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Successfully unmuted user/feed'),
        ),
      );
    } catch (e) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to unmute user/feed'),
        ),
      );
      rethrow;
    }
  }

  List<Widget> buildSlivers() {
    final profileViewModel = context.read<ProfileViewModel>();

    return [
      SliverAppBar(
        title: Text(profileViewModel.name),
        pinned: true,
        elevation: 0,
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child: AvatarWithBorder(
                      imageUrl: profileViewModel.twter.avatar.toString(),
                      radius: 40,
                      borderThickness: 4,
                      borderColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  if (!profileViewModel.isProfileExternal)
                    Flexible(
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: profileViewModel.hasFollowing
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        fullscreenDialog: true,
                                        builder: (context) {
                                          return UserList(
                                            usersAndURL:
                                                profileViewModel.following,
                                            title: 'Following',
                                          );
                                        },
                                      ),
                                    );
                                  }
                                : null,
                            child: Column(
                              children: [
                                Text(
                                  profileViewModel.followingCount.toString(),
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                Text('Following')
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: profileViewModel.hasFollowers
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        fullscreenDialog: true,
                                        builder: (context) {
                                          return UserList(
                                            usersAndURL:
                                                profileViewModel.followers,
                                            title: 'Followers',
                                          );
                                        },
                                      ),
                                    );
                                  }
                                : null,
                            child: Column(
                              children: [
                                Text(
                                  profileViewModel.followerCount.toString(),
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                Text('Followers')
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: Text(profileViewModel.profile.tagline),
                  ),
                  Flexible(
                    flex: 1,
                    child: SizedBox(),
                  ),
                ],
              ),
              Divider(),
            ],
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildListDelegate.fixed(
          [
            ListTile(
              dense: true,
              title: Text('Twtxt'),
              leading: Icon(Icons.link),
              onTap: () async {
                final link = profileViewModel.profile.uri.toString();
                if (await canLaunch(link)) {
                  await launch(link);
                  return;
                }
              },
            ),
            Consumer<User>(
              builder: (context, user, _) {
                if (profileViewModel.isViewingOwnProfile) {
                  return Container();
                }

                if (profileViewModel.isFollowing) {
                  return FutureBuilder(
                    future: _unFollowFuture,
                    builder: (context, snapshot) {
                      Widget leading = Icon(Icons.person_remove);
                      Function onTap = () {
                        setState(() {
                          _unFollowFuture = _unFollow(
                            profileViewModel.twter.nick,
                            context,
                          );
                        });
                      };

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        leading = SizedSpinner();
                        onTap = null;
                      }

                      return ListTile(
                        dense: true,
                        title: Text('Unfollow'),
                        leading: leading,
                        onTap: onTap,
                      );
                    },
                  );
                }

                return FutureBuilder(
                  future: _followFuture,
                  builder: (context, snapshot) {
                    Widget leading = Icon(Icons.person_add_alt);
                    Function onTap = () {
                      setState(() {
                        _followFuture = _follow(
                          profileViewModel.profile.username,
                          profileViewModel.profile.uri.toString(),
                          context,
                        );
                      });
                    };

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      leading = SizedSpinner();
                      onTap = null;
                    }

                    return ListTile(
                      dense: true,
                      title: Text('Follow'),
                      leading: leading,
                      onTap: onTap,
                    );
                  },
                );
              },
            ),
            ListTile(
              dense: true,
              title: Text('Report'),
              leading: Icon(Icons.report),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (context) {
                      return Report(
                        nick: profileViewModel.profile.username,
                        url: profileViewModel.profile.uri.toString(),
                      );
                    },
                  ),
                );
              },
            ),
            FutureBuilder(
              future: _muteFuture,
              builder: (context, snapshot) {
                final isLoading =
                    snapshot.connectionState == ConnectionState.waiting;
                if (profileViewModel.profile.muted) {
                  return ListTile(
                    dense: true,
                    onTap: isLoading
                        ? null
                        : () {
                            setState(() {
                              _muteFuture = _unmute(context);
                            });
                          },
                    title: Text('Unmute'),
                    leading:
                        isLoading ? SizedSpinner() : Icon(Icons.volume_down),
                  );
                }

                return ListTile(
                  onTap: isLoading
                      ? null
                      : () {
                          setState(() {
                            _muteFuture = _mute(context);
                          });
                        },
                  dense: true,
                  title: Text('Mute'),
                  leading: isLoading ? SizedSpinner() : Icon(Icons.volume_mute),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(),
            ),
          ],
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final user = context.watch<User>();
    return FutureBuilder(
      future: _fetchProfileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(vm.name),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(vm.name),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load profile'),
                  SizedBox(height: 32),
                  RaisedButton(
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () {
                      setState(() {
                        _fetchProfileFuture = _fetchProfile();
                      });
                    },
                    child: const Text('Tap to retry'),
                  )
                ],
              ),
            ),
          );
        }

        return Scaffold(
          floatingActionButton: Builder(
            builder: (context) => FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async {
                var mention = '${vm.profile.mention} ';
                if (user.profile.username == vm.profile.username) {
                  mention = "";
                }

                if (await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewTwt(initialText: mention),
                      ),
                    ) ??
                    false) {
                  await context.read<ProfileViewModel>().refreshPost();
                }
              },
            ),
          ),
          body: PostList(
            gotoNextPage: vm.gotoNextPage,
            fetchNewPost: vm.refreshPost,
            twts: vm.twts,
            fetchMoreState: vm.fetchMoreState,
            topSlivers: buildSlivers(),
          ),
        );
      },
    );
  }
}

class UserList extends StatelessWidget {
  const UserList({
    Key key,
    @required this.usersAndURL,
    @required this.title,
  }) : super(key: key);

  final String title;
  final Map<String, String> usersAndURL;

  List<MapEntry<String, String>> get _usersAndURLEntry =>
      usersAndURL.entries.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0,
            title: Text(title),
            pinned: true,
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final entry = _usersAndURLEntry[index];
                return ListTile(
                  title: Text(entry.key),
                  subtitle: Text(Uri.parse(entry.value).host),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ChangeNotifierProvider(
                            create: (_) => ProfileViewModel(
                                context.read<Api>(),
                                Twter(
                                  nick: entry.key,
                                  uri: Uri.parse(entry.value),
                                ),
                                context.read<User>().profile),
                            child: ProfileScreen(),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              childCount: usersAndURL.length,
            ),
          )
        ],
      ),
    );
  }
}
