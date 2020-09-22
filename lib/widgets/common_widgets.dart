import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:goryon/strings.dart';
import 'package:jiffy/jiffy.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:goryon/screens/profile.dart';

import '../api.dart';
import '../models.dart';
import '../screens/discover.dart';
import '../screens/follow.dart';
import '../screens/newtwt.dart';
import '../screens/timeline.dart';
import '../viewmodels.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    Key key,
    @required this.imageUrl,
    this.radius = 20,
  }) : super(key: key);

  final String imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return CircleAvatar(radius: radius);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      httpHeaders: {HttpHeaders.acceptHeader: "image/webp"},
      imageBuilder: (context, imageProvider) {
        return CircleAvatar(backgroundImage: imageProvider, radius: radius);
      },
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}

class SizedSpinner extends StatelessWidget {
  final double height;
  final double width;

  const SizedSpinner({Key key, this.height = 16, this.width = 16})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CircularProgressIndicator(
        strokeWidth: 2,
      ),
    );
  }
}

class AvatarWithBorder extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final Color borderColor;
  final double borderThickness;

  const AvatarWithBorder({
    Key key,
    @required this.imageUrl,
    this.borderColor,
    this.borderThickness = 1,
    this.radius = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          this.borderColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: Avatar(
        imageUrl: imageUrl,
        radius: radius - this.borderThickness,
      ),
    );
  }
}

class AuthWidgetBuilder extends StatelessWidget {
  const AuthWidgetBuilder({Key key, @required this.builder}) : super(key: key);

  final Widget Function(BuildContext, AsyncSnapshot<User>) builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: context.watch<AuthViewModel>().user,
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        final User user = snapshot.data;
        if (user != null) {
          return MultiProvider(
            providers: [
              Provider<User>.value(value: user),
            ],
            child: builder(context, snapshot),
          );
        }
        return builder(context, snapshot);
      },
    );
  }
}

class AppDrawer extends StatelessWidget {
  const AppDrawer(
      {Key key, @required this.activatedRoute, this.avatarRadius = 35})
      : super(key: key);

  final String activatedRoute;
  final double avatarRadius;

  ListTile buildListTile(BuildContext context, String title, String routePath) {
    final isActive = activatedRoute == routePath;
    return ListTile(
      title: Text(title),
      tileColor: isActive ? Theme.of(context).highlightColor : null,
      onTap: isActive
          ? null
          : () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(routePath);
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Consumer<User>(builder: (context, user, _) {
            return UserAccountsDrawerHeader(
              margin: const EdgeInsets.all(0),
              // Avatar border
              currentAccountPicture: AvatarWithBorder(
                radius: avatarRadius,
                imageUrl: user.twter.avatar.toString(),
              ),
              accountName: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.profile.username),
                  Text(user.profile.uri.authority),
                ],
              ),
              accountEmail: null,
            );
          }),
          buildListTile(context, 'Discover', Discover.routePath),
          buildListTile(context, 'Timeline', Timeline.routePath),
          buildListTile(context, 'Follow', Follow.routePath),
          ListTile(
            title: Text('Log Out'),
            trailing: Icon(Icons.logout),
            onTap: () {
              Navigator.of(context).pop();
              context.read<AuthViewModel>().logout();
            },
          )
        ],
      ),
    );
  }
}

class PostList extends StatefulWidget {
  const PostList({
    Key key,
    @required this.fetchNewPost,
    @required this.gotoNextPage,
    @required this.twts,
    @required this.isBottomListLoading,
    this.topSlivers = const <Widget>[],
  }) : super(key: key);

  final Function fetchNewPost;
  final Function gotoNextPage;
  final bool isBottomListLoading;
  final List<Twt> twts;
  final List<Widget> topSlivers;

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(initiateLoadMoreOnScroll);
  }

  void initiateLoadMoreOnScroll() {
    if (_scrollController.position.pixels >
            _scrollController.position.maxScrollExtent * 0.9 &&
        !widget.isBottomListLoading) {
      widget.gotoNextPage();
    }
  }

  void pushToProfileScreen(
    BuildContext context,
    Twter twter,
  ) {
    final user = context.read<User>();
    final api = context.read<Api>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ChangeNotifierProvider(
            create: (_) => ProfileViewModel(api, twter, user.profile),
            child: ProfileScreen(),
          );
        },
      ),
    );
  }

  Twter getNickFromTwtxtURL(Uri uriFromMarkdown, Uri uriFromLoggedInUser) {
    if (uriFromMarkdown.pathSegments.length == 2 &&
        uriFromMarkdown.pathSegments.first == "user") {
      return Twter(nick: uriFromMarkdown.pathSegments[1]);
    }

    if (uriFromMarkdown.pathSegments.length == 3 &&
        uriFromMarkdown.pathSegments.first == "external") {
      return Twter(
        slug: uriFromMarkdown.pathSegments[1],
        nick: uriFromMarkdown.pathSegments[2],
      );
    }

    return null;
  }

  Widget buildMarkdownBody(BuildContext context, Twt twt) {
    final user = context.read<User>();
    final appStrings = context.read<AppStrings>();

    return MarkdownBody(
      imageBuilder: (uri, title, alt) => Builder(
        builder: (context) {
          Uri newUri = uri;
          bool isVideoThumbnail = false;

          if (path.extension(uri.path) == '.webm') {
            isVideoThumbnail = true;
            newUri = uri.replace(
              path: '${path.withoutExtension(uri.path)}.webp',
            );
          }

          void onTap() async {
            if (await canLaunch(uri.toString())) {
              await launch(uri.toString());
              return;
            }

            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(appStrings.failLaunchImageToBrowser),
              ),
            );
          }

          return GestureDetector(
            onTap: onTap,
            child: CachedNetworkImage(
              httpHeaders: {HttpHeaders.acceptHeader: "image/webp"},
              imageUrl: newUri.toString(),
              placeholder: (context, url) => CircularProgressIndicator(),
              imageBuilder: (context, imageProvider) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Image(image: imageProvider),
                    if (isVideoThumbnail)
                      Center(
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 100.0,
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
      onTapLink: (link) async {
        final twter = getNickFromTwtxtURL(Uri.parse(link), user.profile.uri);
        if (twter != null) {
          pushToProfileScreen(context, twter);
          return;
        }

        if (await canLaunch(link)) {
          await launch(link);
          return;
        }

        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('${appStrings.failLaunch} $link'),
          ),
        );
      },
      data: twt.text,
      extensionSet: md.ExtensionSet.gitHubWeb,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User>();

    return CustomScrollView(
      cacheExtent: 1000,
      controller: _scrollController,
      slivers: [
        ...widget.topSlivers,
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, idx) {
              final twt = widget.twts[idx];

              return ListTile(
                isThreeLine: true,
                title: GestureDetector(
                  onTap: () {
                    pushToProfileScreen(context, twt.twter);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Avatar(imageUrl: twt.twter.avatar.toString()),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            twt.twter.nick,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                Jiffy(twt.createdTime.toLocal()).format('jm'),
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                              SizedBox(width: 8),
                              Text(
                                '(${Jiffy(twt.createdTime).fromNow()})',
                                style: Theme.of(context).textTheme.bodyText2,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: buildMarkdownBody(context, twt),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: StadiumBorder(),
                      ),
                      onPressed: () async {
                        if (await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NewTwt(
                                  initialText: twt.replyText(
                                    user.profile.username,
                                  ),
                                ),
                              ),
                            ) ??
                            false) {
                          widget.fetchNewPost();
                        }
                      },
                      child: Text(
                        "Reply",
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                    Divider(height: 0),
                  ],
                ),
              );
            },
            childCount: widget.twts.length,
          ),
        ),
        if (widget.isBottomListLoading)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 64.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
      ],
    );
  }
}
