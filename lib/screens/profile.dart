import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../api.dart';
import '../common_widgets.dart';
import '../models.dart';
import '../viewmodels.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final Uri uri;
  final bool isExternalProfile;

  const ProfileScreen({
    Key key,
    @required this.name,
    @required this.uri,
    @required this.isExternalProfile,
  }) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future _fetchProfileFuture;
  @override
  void initState() {
    super.initState();
    _fetchProfileFuture = _fetchProfile();
  }

  Future _fetchProfile() async {
    try {
      if (widget.isExternalProfile) {
        await context.read<ProfileViewModel>().fetchProfile(
              widget.name,
              widget.uri.toString(),
            );
      } else {
        await context.read<ProfileViewModel>().fetchProfile(widget.name);
      }
    } on http.ClientException catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      print(e);
    }
  }

  List<Widget> buildSlivers() {
    final profileViewModel = context.read<ProfileViewModel>();

    return [
      SliverAppBar(title: Text(widget.name)),
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
                  if (!widget.isExternalProfile)
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
              onTap: () {},
            ),
            Consumer<User>(
              builder: (context, user, _) {
                if (user.profile.isFollowing(widget.uri.toString())) {
                  return ListTile(
                    dense: true,
                    title: Text('Unfollow'),
                    leading: Icon(Icons.person_remove_sharp),
                    onTap: () {},
                  );
                }

                return ListTile(
                  dense: true,
                  title: Text('Follow'),
                  leading: Icon(Icons.person_add_alt),
                  onTap: () {},
                );
              },
            ),
            if (!widget.isExternalProfile) ...[
              ListTile(
                dense: true,
                title: Text('Blogs'),
                leading: Icon(Icons.list_alt),
                onTap: () {},
              ),
              ListTile(
                dense: true,
                title: Text('Atom'),
                leading: Icon(Icons.rss_feed),
                onTap: () {},
              ),
            ],
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
            floating: true,
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
                              isExternalProfile: false,
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
