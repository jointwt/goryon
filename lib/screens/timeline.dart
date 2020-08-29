import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../common_widgets.dart';
import '../models.dart';
import '../viewmodels.dart';
import 'newtwt.dart';

class Timeline extends StatefulWidget {
  static const String routePath = "/";
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _page());
  }

  void _page() async {
    try {
      context.read<TimelineViewModel>().gotoNextPage();
    } on http.ClientException catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(activatedRoute: Timeline.routePath),
      appBar: AppBar(
        textTheme: Theme.of(context).textTheme,
        title: const Text('Timeline'),
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
              context.read<TimelineViewModel>().fetchNewPost();
            }
          },
        ),
      ),
      body: Consumer2<TimelineViewModel, User>(
        builder: (context, timelineViewModel, user, _) {
          if (timelineViewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: timelineViewModel.refreshPost,
            child: PostList(
              fetchNewPost: timelineViewModel.fetchNewPost,
              twts: timelineViewModel.twts,
            ),
          );
        },
      ),
    );
  }
}
