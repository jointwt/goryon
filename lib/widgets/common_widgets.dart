import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:goryon/screens/conversation.dart';
import 'package:share/share.dart';
import 'package:goryon/strings.dart';
import 'package:jiffy/jiffy.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:goryon/screens/profile.dart';

import '../api.dart';
import '../models.dart';
import '../screens/discover.dart';
import '../screens/follow.dart';
import '../screens/newtwt.dart';
import '../screens/timeline.dart';
import '../screens/mentions.dart';
import '../screens/videoscreen.dart';
import '../viewmodels.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    Key key,
    @required this.imageUrl,
    this.radius = 20,
  }) : super(key: key);

  final String imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return CircleAvatar(radius: radius);
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      httpHeaders: {HttpHeaders.acceptHeader: "image/webp"},
      imageBuilder: (context, imageProvider) {
        return CircleAvatar(backgroundImage: imageProvider, radius: radius);
      },
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}

class SizedSpinner extends StatelessWidget {
  final double height;
  final double width;

  const SizedSpinner({Key key, this.height = 16, this.width = 16})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: CircularProgressIndicator(
        strokeWidth: 2,
      ),
    );
  }
}

class AvatarWithBorder extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final Color borderColor;
  final double borderThickness;

  const AvatarWithBorder({
    Key key,
    @required this.imageUrl,
    this.borderColor,
    this.borderThickness = 1,
    this.radius = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          this.borderColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: Avatar(
        imageUrl: imageUrl,
        radius: radius - this.borderThickness,
      ),
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
  const AppDrawer(
      {Key key, @required this.activatedRoute, this.avatarRadius = 35})
      : super(key: key);

  final String activatedRoute;
  final double avatarRadius;

  ListTile buildListTile(BuildContext context, String title, String routePath) {
    final isActive = activatedRoute == routePath;
    return ListTile(
      title: Text(title),
      tileColor: isActive ? Theme.of(context).highlightColor : null,
      onTap: isActive
          ? null
          : () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed(routePath);
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Consumer<User>(builder: (context, user, _) {
            return UserAccountsDrawerHeader(
              margin: const EdgeInsets.all(0),
              // Avatar border
              currentAccountPicture: AvatarWithBorder(
                radius: avatarRadius,
                imageUrl: user.twter.avatar.toString(),
              ),
              accountName: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.profile.username),
                  Text(user.profile.uri.authority),
                ],
              ),
              accountEmail: null,
            );
          }),
          buildListTile(context, 'Discover', Discover.routePath),
          buildListTile(context, 'Timeline', Timeline.routePath),
          buildListTile(context, 'Follow', Follow.routePath),
          buildListTile(context, 'Mentions', Mentions.routePath),
          SwitchListTile(
            title: Text("Dark mode"),
            value: themeVM.isDarkModeEnabled &&
                Theme.of(context).brightness == Brightness.dark,
            onChanged: themeVM.toggleDarkMode,
          ),
          ListTile(
            title: Text('Log Out'),
            trailing: Icon(Icons.logout),
            onTap: () {
              Navigator.of(context).pop();
              context.read<AuthViewModel>().logout();
            },
          )
        ],
      ),
    );
  }
}

class PostActions extends StatelessWidget {
  final Twt twt;

  const PostActions({
    Key key,
    @required this.twt,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Icon(Icons.drag_handle),
                ),
              ),
              ListTile(
                leading: Icon(Icons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  Share.share(context
                      .read<User>()
                      .profile
                      .uri
                      .replace(
                        path: "/twt/${twt.hash}",
                      )
                      .toString());
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: RaisedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class PostList extends StatefulWidget {
  const PostList({
    Key key,
    @required this.fetchNewPost,
    @required this.gotoNextPage,
    @required this.twts,
    @required this.fetchMoreState,
    this.topSlivers = const <Widget>[],
    this.afterReply,
    this.showReplyButton = true,
    this.showConversationButton = true,
  }) : super(key: key);

  final Function fetchNewPost;
  final Function gotoNextPage;
  final List<Twt> twts;
  final List<Widget> topSlivers;
  final FetchState fetchMoreState;
  final bool showReplyButton;
  final bool showConversationButton;
  final Function() afterReply;

  @override
  _PostListState createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(initiateLoadMoreOnScroll);
  }

  void initiateLoadMoreOnScroll() {
    if (_scrollController.position.pixels >
            _scrollController.position.maxScrollExtent * 0.9 &&
        widget.fetchMoreState == FetchState.Done) {
      widget.gotoNextPage();
    }
  }

  void pushToProfileScreen(
    BuildContext context,
    Twter twter,
  ) {
    final user = context.read<User>();
    final api = context.read<Api>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ChangeNotifierProvider(
            create: (_) => ProfileViewModel(api, twter, user.profile),
            child: ProfileScreen(),
          );
        },
      ),
    );
  }

  Twter getNickFromTwtxtURL(String link) {
    Uri uri;
    try {
      uri = Uri.parse(link);
      if (uri.pathSegments.last != "twtxt.txt") {
        return null;
      }
    } catch (e) {
      return null;
    }

    return Twter(nick: uri.fragment, uri: uri.replace(fragment: ""));
  }

  Widget buildMarkdownBody(BuildContext context, Twt twt) {
    final appStrings = context.read<AppStrings>();

    return MarkdownBody(
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        blockquoteDecoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
      imageBuilder: (uri, title, alt) => Builder(
        builder: (context) {
          Uri thumbnailURI = uri;
          bool isVideoThumbnail = false;

          if (path.extension(uri.path) == '.webm') {
            isVideoThumbnail = true;
            thumbnailURI = uri.replace(
              path: '${path.withoutExtension(uri.path)}',
            );
          }

          void onTap() async {
            if (isVideoThumbnail) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoScreen(
                    title: title,
                    videoURL: thumbnailURI
                        .replace(
                          path:
                              "${thumbnailURI.path}.${Platform.isIOS ? 'mp4' : 'webm'}",
                        )
                        .toString(),
                  ),
                ),
              );
              return;
            }

            if (await canLaunch(uri.toString())) {
              await launch(uri.toString());
              return;
            }

            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text(appStrings.failLaunchImageToBrowser),
              ),
            );
          }

          return GestureDetector(
            onTap: onTap,
            child: CachedNetworkImage(
              httpHeaders: {HttpHeaders.acceptHeader: "image/webp"},
              imageUrl: thumbnailURI.toString(),
              placeholder: (context, url) => CircularProgressIndicator(),
              imageBuilder: (context, imageProvider) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Image(image: imageProvider),
                    if (isVideoThumbnail)
                      Center(
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 100.0,
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
      onTapLink: (link) async {
        final twter = getNickFromTwtxtURL(link);
        if (twter != null) {
          pushToProfileScreen(context, twter);
          return;
        }

        if (await canLaunch(link)) {
          await launch(link);
          return;
        }

        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('${appStrings.failLaunch} $link'),
          ),
        );
      },
      data: twt.cleanMDText,
      extensionSet: md.ExtensionSet.gitHubWeb,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User>();

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        ...widget.topSlivers,
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, idx) {
              final twt = widget.twts[idx];

              return ListTile(
                contentPadding: EdgeInsets.fromLTRB(16, 16, 8, 6),
                isThreeLine: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        pushToProfileScreen(context, twt.twter);
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Avatar(imageUrl: twt.twter.avatar.toString()),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                twt.twter.nick,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    Jiffy(twt.createdTime.toLocal())
                                        .format('jm'),
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    '(${Jiffy(twt.createdTime).fromNow()})',
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Material(
                        child: InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.more_vert,
                              size: 16,
                            ),
                          ),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              builder: (context) => Container(
                                child: PostActions(twt: twt),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                      child: buildMarkdownBody(context, twt),
                    ),
                    Row(
                      children: [
                        if (widget.showReplyButton)
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: StadiumBorder(),
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NewTwt(
                                    initialText: twt.replyText(
                                      user.profile.username,
                                    ),
                                  ),
                                ),
                              );
                              widget.afterReply?.call();
                            },
                            child: Text(
                              "Reply",
                              style: Theme.of(context).textTheme.button,
                            ),
                          ),
                        SizedBox(width: 8),
                        if (widget.showConversationButton &&
                            twt.subject.isNotEmpty)
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: StadiumBorder(),
                            ),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChangeNotifierProvider(
                                    create: (_) => ConversationViewModel(
                                      context.read<Api>(),
                                      twt,
                                    ),
                                    child: Conversation(),
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "Conversation",
                              style: Theme.of(context).textTheme.button,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
            childCount: widget.twts.length,
          ),
        ),
        SliverToBoxAdapter(
          child: Builder(
            builder: (context) {
              switch (widget.fetchMoreState) {
                case FetchState.Loading:
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 64.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                case FetchState.Error:
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: UnexpectedErrorMessage(
                      onRetryPressed: widget.gotoNextPage,
                    ),
                  );
                default:
                  return SizedBox.shrink();
              }
            },
          ),
        )
      ],
    );
  }
}

class UnexpectedErrorMessage extends StatelessWidget {
  final VoidCallback onRetryPressed;
  final String description;
  final String buttonLabel;
  const UnexpectedErrorMessage({
    Key key,
    this.onRetryPressed,
    this.buttonLabel,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppStrings>();
    return ErrorMessage(
      onButtonPressed: onRetryPressed,
      description: Column(
        children: [
          Text(
            description ?? strings.unexpectedError,
            style: Theme.of(context).textTheme.bodyText1,
          ),
          SizedBox(height: 32),
        ],
      ),
      buttonChild: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.refresh),
          SizedBox(width: 8),
          Text(buttonLabel ?? strings.tapToRetry),
        ],
      ),
    );
  }
}

class ErrorMessage extends StatelessWidget {
  final VoidCallback onButtonPressed;
  final Widget description;
  final Widget buttonChild;
  const ErrorMessage({
    Key key,
    this.onButtonPressed,
    this.buttonChild,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          description,
          RaisedButton(
            color: Theme.of(context).colorScheme.error,
            onPressed: onButtonPressed,
            child: buttonChild,
          )
        ],
      ),
    );
  }
}

class DropdownFormField<T> extends FormField<T> {
  DropdownFormField(
    BuildContext context,
    List<DropdownMenuItem<T>> dropDownItems, {
    FormFieldSetter<T> onSaved,
    FormFieldValidator<T> validator,
    T initialValue,
    bool isExpanded = false,
    Widget hint,
  }) : super(
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue,
          builder: (FormFieldState<T> state) {
            final theme = Theme.of(context);
            return Column(
              children: [
                DropdownButton<T>(
                  onTap: () {
                    // https://github.com/flutter/flutter/issues/47128#issuecomment-627551073
                    FocusManager.instance.primaryFocus.unfocus();
                  },
                  value: state.value,
                  isExpanded: isExpanded,
                  items: dropDownItems,
                  underline: Container(
                    height: 1.0,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: state.hasError
                              ? theme.errorColor
                              : Color(0xFFBDBDBD),
                          width: state.hasError ? 1.0 : 0.0,
                        ),
                      ),
                    ),
                  ),
                  hint: hint,
                  onChanged: (changedValue) {
                    state.didChange(changedValue);
                  },
                ),
                if (state.hasError) ...[
                  SizedBox(height: 2),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      state.errorText,
                      style: theme.textTheme.caption.copyWith(
                        color: theme.errorColor,
                      ),
                    ),
                  )
                ]
              ],
            );
          },
        );
}
