import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twtxt_flutter/screens/discover.dart';
import 'package:twtxt_flutter/screens/follow.dart';

import '../api.dart';
import '../models.dart';
import '../viewmodels.dart';
import 'login.dart';
import 'timeline.dart';

class AuthWidget extends StatefulWidget {
  const AuthWidget({Key key, this.snapshot}) : super(key: key);

  final AsyncSnapshot<User> snapshot;

  @override
  _AuthWidgetState createState() => _AuthWidgetState();
}

class _AuthWidgetState extends State<AuthWidget> {
  StreamSubscription _userSub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_userSub == null) {
      _userSub = context
          .read<AuthViewModel>()
          .user
          .where((user) => user == null)
          .listen((_) => Navigator.popUntil(context, (route) => route.isFirst));
    }
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.snapshot.connectionState == ConnectionState.active) {
      return widget.snapshot.hasData ? Home() : Login();
    }

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final _api = context.watch<Api>();
    return Navigator(
      initialRoute: Timeline.routePath,
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case Timeline.routePath:
            builder = (_) => ChangeNotifierProvider(
                  create: (_) => TimelineViewModel(_api),
                  child: Timeline(),
                );
            break;
          case Discover.routePath:
            builder = (_) => ChangeNotifierProvider(
                  create: (_) => DiscoverViewModel(_api),
                  child: Discover(),
                );
            break;
          case Follow.routePath:
            builder = (_) => Follow();
            break;
          default:
            throw Exception('Invalid route: ${settings.name}');
        }

        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }
}
