import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../common_widgets.dart';
import '../models.dart';
import '../viewmodels.dart';

class ProfileScreen extends StatefulWidget {
  final String name;
  final Uri avatar;
  final Uri uri;

  const ProfileScreen({
    Key key,
    @required this.name,
    @required this.avatar,
    @required this.uri,
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
    if (widget.uri.authority != context.read<User>().podURL.authority) {
      return;
    }

    try {
      await context.read<ProfileViewModel>().fetchProfile(widget.name);
    } on http.ClientException catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      print(e);
    }
  }

  List<Widget> buildSlivers() {
    // final profileViewModel = context.read<ProfileViewModel>();

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
                    child: Avatar(
                      imageUrl: widget.avatar.toString(),
                      radius: 40,
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('100',
                                style: Theme.of(context).textTheme.headline6),
                            Text('Following')
                          ],
                        ),
                        Column(
                          children: [
                            Text('100',
                                style: Theme.of(context).textTheme.headline6),
                            Text('Followers')
                          ],
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
                    child: Text('My description ' * 5),
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
              title: Text('Blogs'),
              leading: Icon(Icons.list_alt),
              onTap: () {},
            ),
            ListTile(
              dense: true,
              title: Text('Twtxt'),
              leading: Icon(Icons.link),
              onTap: () {},
            ),
            ListTile(
              dense: true,
              title: Text('Atom'),
              leading: Icon(Icons.rss_feed),
              onTap: () {},
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

        return Scaffold(
          body: CustomScrollView(
            slivers: buildSlivers(),
          ),
        );
      },
    );
  }
}
