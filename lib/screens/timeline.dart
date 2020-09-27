import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/common_widgets.dart';
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
    Future.microtask(() => context.read<TimelineViewModel>().fetchNewPost());
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
                  MaterialPageRoute(builder: (_) => NewTwt()),
                ) ??
                false) {
              context.read<TimelineViewModel>().fetchNewPost();
            }
          },
        ),
      ),
      body: Consumer<TimelineViewModel>(
        builder: (context, vm, _) {
          switch (vm.mainListState) {
            case FetchState.Loading:
              return Center(child: CircularProgressIndicator());
            case FetchState.Error:
              return UnexpectedErrorMessage(
                onRetryPressed: vm.gotoNextPage,
              );
            default:
              return RefreshIndicator(
                onRefresh: vm.refreshPost,
                child: PostList(
                  gotoNextPage: vm.gotoNextPage,
                  fetchNewPost: vm.fetchNewPost,
                  fetchMoreState: vm.fetchMoreState,
                  twts: vm.twts,
                ),
              );
          }
        },
      ),
    );
  }
}
