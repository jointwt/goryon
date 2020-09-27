import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/common_widgets.dart';
import '../viewmodels.dart';
import 'newtwt.dart';

class Discover extends StatefulWidget {
  static const String routePath = '/discover';

  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DiscoverViewModel>().fetchNewPost());
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
                  MaterialPageRoute(builder: (_) => NewTwt()),
                ) ??
                false) {
              context.read<DiscoverViewModel>().fetchNewPost();
            }
          },
        ),
      ),
      body: Consumer<DiscoverViewModel>(
        builder: (context, vm, _) {
          switch (vm.mainListState) {
            case FetchState.Loading:
              return Center(child: CircularProgressIndicator());
            case FetchState.Error:
              return UnexpectedErrorMessage(
                onRetryPressed: vm.fetchNewPost,
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
