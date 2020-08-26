import 'package:flutter/material.dart';

import '../common_widgets.dart';

class Follow extends StatefulWidget {
  static const String routePath = '/follow';

  @override
  _FollowState createState() => _FollowState();
}

class _FollowState extends State<Follow> {
  bool _canSubmit = false;
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _urlController = TextEditingController();

  Widget buildSuccessMessagePage(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(32),
          shrinkWrap: true,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                'Successfully followed ${_nicknameController.text}',
              ),
            ),
            SizedBox(height: 64),
            Container(
              child: RaisedButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Follow')),
      floatingActionButton: FutureBuilder(builder: (context, snapshot) {
        Widget label = const Text("Follow");

        if (snapshot.connectionState == ConnectionState.waiting)
          label = SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );

        return FloatingActionButton.extended(
          label: label,
          elevation: _canSubmit ? 2 : 0,
          backgroundColor: _canSubmit ? null : Theme.of(context).disabledColor,
          onPressed: _canSubmit
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => buildSuccessMessagePage(context),
                    ),
                  );
                }
              : null,
        );
      }),
      drawer: const AppDrawer(activatedRoute: Follow.routePath),
      body: Form(
        onChanged: () {
          print("Can submit");
          print(_nicknameController.text.trim().isNotEmpty ||
              _urlController.text.trim().isNotEmpty);
          setState(() => _canSubmit =
              _nicknameController.text.trim().isNotEmpty ||
                  _urlController.text.trim().isNotEmpty);
        },
        child: ListView(
          children: [
            ListTile(
              title: Text(
                'Follow a new user or feed',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: 'Enter the nickname of user/feed',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                keyboardType: TextInputType.url,
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'Enter the url of user/feed',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
