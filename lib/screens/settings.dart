import 'package:flutter/material.dart';
import 'package:goryon/models.dart';
import 'package:goryon/widgets/image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:goryon/widgets/common_widgets.dart';

import '../form_validators.dart';

class Settings extends StatefulWidget {
  static const String routePath = "/settings";
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _taglineController = TextEditingController();
  final _emailController = TextEditingController();
  final _picker = ImagePicker();
  String _avatarURL;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = context.read<User>();
      _taglineController.text = user.profile.tagline;
      setState(() {
        _avatarURL = user.twter.avatar.toString();
      });
    });
  }

  ListView buildBody(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: () {
              getImage(context, _picker).then((value) {
                WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
                if (value == null) return;
                setState(() {
                  _avatarURL = value.path;
                });
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                AvatarWithBorder(
                  imageUrl: _avatarURL,
                  radius: 36.0,
                ),
                Positioned(
                  child: Icon(Icons.camera),
                  right: 0,
                  bottom: 0,
                  left: 36.0,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextFormField(
            validator: FormValidators.requiredField,
            controller: _taglineController,
            decoration: InputDecoration(
              labelText: 'Tagline',
              helperText:
                  'A short description, catchphrase or slogan about yourself',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextFormField(
            validator: FormValidators.requiredField,
            controller: _taglineController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              helperText: 'Updated password',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextFormField(
            validator: FormValidators.requiredField,
            controller: _taglineController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Email',
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Builder(
        builder: (context) {
          return buildBody(context);
        },
      ),
    );
  }
}
