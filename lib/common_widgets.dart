import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goryon/viewmodels.dart';

import 'models.dart';
import 'screens/discover.dart';
import 'screens/follow.dart';
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
  final String activatedRoute;

  const AppDrawer({Key key, @required this.activatedRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final highlightColor = Theme.of(context).highlightColor;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Consumer<User>(builder: (context, user, _) {
            return UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                radius: 35,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: Avatar(
                  imageUrl: user.imageUrl,
                  radius: 34,
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
          ListTile(
            title: Text('Discover'),
            tileColor:
                activatedRoute == Discover.routePath ? highlightColor : null,
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(Discover.routePath);
            },
          ),
          ListTile(
            tileColor:
                activatedRoute == Timeline.routePath ? highlightColor : null,
            title: Text('Timeline'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(Timeline.routePath);
            },
          ),
          ListTile(
            tileColor:
                activatedRoute == Follow.routePath ? highlightColor : null,
            title: Text('Follow'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(Follow.routePath);
            },
          ),
          ListTile(
            title: Text('Log Out'),
            trailing: Icon(Icons.logout),
            onTap: () {
              Navigator.of(context).pop();
              context.watch<AuthViewModel>().logout();
            },
          )
        ],
      ),
    );
  }
}
