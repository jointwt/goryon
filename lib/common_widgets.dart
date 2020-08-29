import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'viewmodels.dart';
import 'models.dart';
import 'screens/discover.dart';
import 'screens/follow.dart';
import 'screens/newtwt.dart';
import 'screens/timeline.dart';

class Avatar extends StatelessWidget {
  const Avatar({Key key, this.imageUrl, this.radius = 20}) : super(key: key);

  final String imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return CircleAvatar(radius: radius);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) {
        return CircleAvatar(backgroundImage: imageProvider, radius: radius);
      },
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
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
              currentAccountPicture: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: Avatar(
                  imageUrl: user.imageUrl,
                  radius: avatarRadius - 1,
                ),
              ),
              accountName: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.username),
                  Text(user.podURL.authority),
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
  }) : super(key: key);

  final Function fetchNewPost;
  final Function gotoNextPage;
  final bool isBottomListLoading;
  final List<Twt> twts;

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

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, idx) {
              final twt = widget.twts[idx];
              return ListTile(
                isThreeLine: true,
                leading: Avatar(imageUrl: twt.twter.avatar.toString()),
                title: Text(
                  twt.twter.nick,
                  style: Theme.of(context).textTheme.headline6,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: MarkdownBody(
                        styleSheet: MarkdownStyleSheet(textScaleFactor: 1.2),
                        imageBuilder: (uri, title, alt) => GestureDetector(
                          onTap: () async {
                            if (await canLaunch(uri.toString())) {
                              await launch(uri.toString());
                              return;
                            }

                            Scaffold.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to launch image'),
                              ),
                            );
                          },
                          child: CachedNetworkImage(
                            imageUrl: uri.toString(),
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                          ),
                        ),
                        onTapLink: (link) async {
                          final linkUri = Uri.parse(link);
                          if (linkUri.authority ==
                              context.read<User>().podURL.authority) {
                            // TODO: handle app URLs
                            return;
                          }

                          if (await canLaunch(link)) {
                            await launch(link);
                            return;
                          }

                          Scaffold.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to launch $link'),
                            ),
                          );
                        },
                        data: twt.sanitizedTxt,
                        extensionSet: md.ExtensionSet.gitHubWeb,
                      ),
                    ),
                    Divider(height: 0),
                    ButtonTheme.fromButtonThemeData(
                      data: Theme.of(context).buttonTheme.copyWith(
                            minWidth: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                      child: FlatButton(
                        onPressed: () async {
                          if (await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NewTwt(
                                    initialText: twt.replyText(
                                      context.read<User>().username,
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
