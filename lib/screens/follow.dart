import 'package:flutter/material.dart';
import 'package:goryon/strings.dart';
import 'package:provider/provider.dart';

import '../common_widgets.dart';
import '../form_validators.dart';

class Follow extends StatefulWidget {
  static const String routePath = '/follow';

  @override
  _FollowState createState() => _FollowState();
}

class _FollowState extends State<Follow> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _urlController = TextEditingController();

  Widget buildSuccessMessagePage(BuildContext context) {
    final appStrings = context.read<AppStrings>();
    return WillPopScope(
      onWillPop: () async {
        _nicknameController.clear();
        _urlController.clear();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(elevation: 0),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                '${appStrings.followSuccessful} ${_nicknameController.text}: ${_urlController.text}',
                style: Theme.of(context).textTheme.headline5.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RaisedButton(
                child: const Text('OK'),
                onPressed: () {
                  _nicknameController.clear();
                  _urlController.clear();
                  Navigator.pop(context);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appStrings = context.watch<AppStrings>();
    return Scaffold(
      appBar: AppBar(title: Text(appStrings.follow)),
      floatingActionButton: FutureBuilder(builder: (context, snapshot) {
        Widget label = Text(appStrings.follow);

        if (snapshot.connectionState == ConnectionState.waiting)
          label = SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );

        return FloatingActionButton.extended(
            label: label,
            onPressed: () {
              if (_formKey.currentState.validate()) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => buildSuccessMessagePage(context),
                  ),
                );
              }
            });
      }),
      drawer: const AppDrawer(activatedRoute: Follow.routePath),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            ListTile(
              title: Text(
                appStrings.followHeader,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                validator: FormValidators.requiredField,
                controller: _nicknameController,
                decoration: InputDecoration(
                  labelText: appStrings.followNicknameLabel,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                validator: FormValidators.requiredField,
                keyboardType: TextInputType.url,
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: appStrings.followURLLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
