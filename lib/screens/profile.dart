import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api.dart';
import '../common_widgets.dart';
import '../models.dart';
import '../viewmodels.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final Uri uri;

  const ProfileScreen({
    Key key,
    @required this.name,
    @required this.uri,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future _fetchProfileFuture;
  Future _followFuture;
  Future _unFollowFuture;

  @override
  void initState() {
    super.initState();
    _fetchProfileFuture = _fetchProfile();
  }

  Future _fetchProfile() async {
    await context.read<ProfileViewModel>().fetchProfile(widget.name);
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

  List<Widget> buildSlivers() {
    final profileViewModel = context.read<ProfileViewModel>();

    return [
      SliverAppBar(title: Text(widget.name), pinned: true),
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
                if (user.profile.uri == widget.uri) {
                  return Container();
                }

                if (user.profile.isFollowing(widget.uri.toString())) {
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
                          profileViewModel.twter.nick,
                          profileViewModel.twter.uri.toString(),
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
    return FutureBuilder(
      future: _fetchProfileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.name),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.name),
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
          body: CustomScrollView(
            slivers: buildSlivers(),
          ),
        );
      },
    );
  }
}

class UserList extends StatelessWidget {
  final Map<String, String> usersAndURL;
  final String title;

  const UserList({
    Key key,
    @required this.usersAndURL,
    @required this.title,
  }) : super(key: key);

  List<MapEntry<String, String>> get _usersAndURLEntry =>
      usersAndURL.entries.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
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
                            ),
                            child: ProfileScreen(
                              name: entry.key,
                              uri: Uri.parse(entry.value),
                            ),
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
