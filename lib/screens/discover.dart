import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:markdown/markdown.dart' as md;

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
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _page());
  }

  void _page() async {
    try {
      context.read<DiscoverViewModel>().gotoNextPage();
    } on http.ClientException catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
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
          final twts = discoverViewModel.twts;

          return RefreshIndicator(
            onRefresh: discoverViewModel.refreshPost,
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 16),
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemCount: twts.length,
              itemBuilder: (context, index) {
                final twt = twts[index];
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
                      Divider(),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NewTwt(
                                        initialText:
                                            twt.replyText(user.username),
                                      ),
                                    ),
                                  ) ??
                                  false) {
                                discoverViewModel.fetchNewPost();
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                "Reply",
                                style: Theme.of(context).textTheme.button,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
