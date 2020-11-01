import 'package:flutter/material.dart';
import 'package:goryon/models.dart';
import 'package:goryon/widgets/image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:goryon/widgets/common_widgets.dart';

import '../form_validators.dart';
import '../viewmodels.dart';

class Settings extends StatefulWidget {
  static const String routePath = "/settings";
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _taglineController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _picker = ImagePicker();
  final _themeModes = [
    DropdownMenuItem(child: Text('System'), value: ThemeMode.system),
    DropdownMenuItem(child: Text('Dark'), value: ThemeMode.dark),
    DropdownMenuItem(child: Text('Light'), value: ThemeMode.light),
  ];

  String _avatarURL;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = context.read<AppUser>();
      _taglineController.text = user.profile.tagline;
      setState(() {
        _avatarURL = user.twter.avatar.toString();
      });
    });
  }

  ListView buildBody(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        GestureDetector(
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
                left: 36,
              ),
            ],
          ),
        ),
        TextFormField(
          validator: FormValidators.requiredField,
          controller: _taglineController,
          decoration: InputDecoration(
            labelText: 'Tagline',
            helperText:
                'A short description, catchphrase or slogan about yourself',
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          validator: FormValidators.requiredField,
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Change Password',
            helperText: 'Updated password',
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          validator: FormValidators.requiredField,
          controller: _emailController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Change Email',
            helperText: 'Updated Email',
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<ThemeMode>(
          isExpanded: true,
          items: _themeModes,
          onChanged: (themeMode) {
            themeVM.themeMode = themeMode;
          },
          decoration: InputDecoration(
            labelText: 'Theme',
          ),
          value: themeVM.themeMode,
        ),
        SizedBox(height: 16),
        Text('Privacy Settings', style: Theme.of(context).textTheme.subtitle1),
        SwitchListTile(
          title: Text('Show my followers publicly'),
          value: true,
          onChanged: null,
        ),
        SwitchListTile(
          title: Text('Show my followers publicly'),
          value: true,
          onChanged: null,
        ),
        RaisedButton(
          onPressed: () {},
          child: Text('Submit'),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(activatedRoute: Settings.routePath),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Builder(
        builder: (context) {
          return buildBody(context);
        },
      ),
    );
  }
}
