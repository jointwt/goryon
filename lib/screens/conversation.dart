import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodels.dart';
import '../widgets/common_widgets.dart';
import 'newtwt.dart';

class Conversation extends StatefulWidget {
  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<ConversationViewModel>().fetchNewPost(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ConversationViewModel>();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Conversation'),
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            tooltip: 'Reply',
            child: Icon(Icons.reply),
            onPressed: () async {
              if (await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NewTwt(
                        initialText: vm.replyFabInitialText,
                      ),
                    ),
                  ) ??
                  false) {
                vm.fetchNewPost();
              }
            },
          ),
        ),
        body: Builder(
          builder: (context) {
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
                    showConversationButton: false,
                    showReplyButton: true,
                    gotoNextPage: vm.gotoNextPage,
                    fetchNewPost: vm.fetchNewPost,
                    fetchMoreState: vm.fetchMoreState,
                    twts: vm.twts,
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}
