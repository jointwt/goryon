import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../common_widgets.dart';
import '../models.dart';
import '../viewmodels.dart';
import 'newtwt.dart';

class Discover extends StatefulWidget {
  static const String routePath = '/discover';
  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _page());
    _scrollController.addListener(initiateLoadMoreOnScroll);
  }

  void _page() async {
    try {
      context.read<DiscoverViewModel>().gotoNextPage();
    } on http.ClientException catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      print(e);
    }
  }

  void initiateLoadMoreOnScroll() {
    var triggerFetchMoreSize = 0.9 * _scrollController.position.maxScrollExtent;

    if (_scrollController.position.pixels > triggerFetchMoreSize) {
      _page();
    }
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
              context.read<DiscoverViewModel>().fetchNewPost();
            }
          },
        ),
      ),
      body: Consumer2<DiscoverViewModel, User>(
        builder: (context, discoverViewModel, user, _) {
          if (discoverViewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return RefreshIndicator(
            onRefresh: discoverViewModel.refreshPost,
            child: PostList(
              fetchNewPost: discoverViewModel.fetchNewPost,
              twts: discoverViewModel.twts,
            ),
          );
        },
      ),
    );
  }
}
