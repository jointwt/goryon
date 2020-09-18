import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../widgets/common_widgets.dart';
import '../viewmodels.dart';
import 'newtwt.dart';

class Discover extends StatefulWidget {
  static const String routePath = '/discover';
  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  Future _fetchNewPostFuture;
  @override
  void initState() {
    super.initState();
    _fetchNewPost();
  }

  void _page() async {
    try {
      await context.read<DiscoverViewModel>().gotoNextPage();
    } on http.ClientException catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      print(e);
    }
  }

  void _fetchNewPost() {
    Future<void> _fetch() async {
      try {
        await context.read<DiscoverViewModel>().refreshPost();
      } on http.ClientException catch (e) {
        Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
        rethrow;
      }
    }

    setState(() {
      _fetchNewPostFuture = _fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(activatedRoute: Discover.routePath),
      appBar: AppBar(
        textTheme: Theme.of(context).textTheme,
        title: const Text('Discover'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            if (await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewTwt(),
                  ),
                ) ??
                false) {
              _fetchNewPost();
            }
          },
        ),
      ),
      body: FutureBuilder(
        future: _fetchNewPostFuture,
        builder: (context, snapshot) {
          return Consumer<DiscoverViewModel>(
            builder: (context, discoverViewModel, _) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return RefreshIndicator(
                onRefresh: discoverViewModel.refreshPost,
                child: PostList(
                  isBottomListLoading: discoverViewModel.isBottomListLoading,
                  gotoNextPage: _page,
                  fetchNewPost: _fetchNewPost,
                  twts: discoverViewModel.twts,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
