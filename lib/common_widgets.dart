import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';

import 'package:goryon/viewmodels.dart';

import 'models.dart';
import 'screens/discover.dart';
import 'screens/follow.dart';
import 'screens/newtwt.dart';
import 'screens/timeline.dart';

class Avatar extends StatelessWidget {
  final String imageUrl;
  final double radius;

  const Avatar({Key key, this.imageUrl, this.radius = 20}) : super(key: key);
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
  final double avatarRadius;
  final String activatedRoute;

  const AppDrawer(
      {Key key, @required this.activatedRoute, this.avatarRadius = 35})
      : super(key: key);

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
}

class PostList extends StatelessWidget {
  final List<Twt> twts;
  final Function fetchNewPost;

  const PostList({
    Key key,
    @required this.twts,
    @required this.fetchNewPost,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, idx) {
              final twt = twts[idx];
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
                        onTapLink: (link) {
                          print(link);
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
                                  builder: (_) => NewTwt(initialText: ''
                                      // twt.replyText(user.username),
                                      ),
                                ),
                              ) ??
                              false) {
                            fetchNewPost();
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
            childCount: twts.length,
          ),
        ),
      ],
    );
  }
}
