import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:goryon/api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:goryon/models.dart';
import 'package:goryon/widgets/common_widgets.dart';
import 'package:goryon/widgets/image_picker.dart';

import '../form_validators.dart';
import '../viewmodels.dart';

class Settings extends StatefulWidget {
  static const String routePath = "/settings";
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Future<User> _fetchUserFuture;
  @override
  void initState() {
    super.initState();
    fetchUserSettings();
  }

  void fetchUserSettings() {
    setState(() {
      _fetchUserFuture = context.read<Api>().getUserSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(activatedRoute: Settings.routePath),
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: FutureBuilder<User>(
        future: _fetchUserFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return UnexpectedErrorMessage(
              onRetryPressed: () {
                fetchUserSettings();
              },
            );
          }

          if (snapshot.hasData) {
            final user = snapshot.data;
            return SettingsBody(
              tagline: user.tagline,
              email: user.email,
              imageURL: context.watch<AppUser>().twter.avatar.toString(),
              isFollowersPubliclyVisible: user.isFollowersPubliclyVisible,
              isFollowingPubliclyVisible: user.isFollowingPubliclyVisible,
            );
          }

          return Container();
        },
      ),
    );
  }
}

class SettingsBody extends StatefulWidget {
  final String tagline, email, imageURL;
  final bool isFollowersPubliclyVisible, isFollowingPubliclyVisible;

  const SettingsBody({
    Key key,
    @required this.tagline,
    @required this.email,
    @required this.imageURL,
    @required this.isFollowersPubliclyVisible,
    @required this.isFollowingPubliclyVisible,
  }) : super(key: key);
  @override
  _SettingsBodyState createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<SettingsBody> {
  final _taglineController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _picker = ImagePicker();
  final _themeModes = [
    DropdownMenuItem(child: Text('System'), value: ThemeMode.system),
    DropdownMenuItem(child: Text('Dark'), value: ThemeMode.dark),
    DropdownMenuItem(child: Text('Light'), value: ThemeMode.light),
  ];

  Future _saveSettingsFuture;
  String _avatarURL;

  bool _isFollowersPubliclyVisible;
  bool _isFollowingPubliclyVisible;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    _taglineController.text = widget.tagline;
    _avatarURL = widget.imageURL;
    _isFollowersPubliclyVisible = widget.isFollowersPubliclyVisible;
    _isFollowingPubliclyVisible = widget.isFollowingPubliclyVisible;
  }

  Future save() async {
    try {
      await context.read<Api>().saveSettings(
          _avatarURL == widget.imageURL ? null : _avatarURL,
          _taglineController.text,
          _passwordController.text,
          _emailController.text,
          _isFollowersPubliclyVisible,
          _isFollowingPubliclyVisible);
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Successfully saved user settings'),
      ));
      await context.read<AuthViewModel>().getAppUser();
      CachedNetworkImage.evictFromCache(widget.imageURL);
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save user settings'),
      ));
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                radius: 40.0,
              ),
              Positioned(
                child: Icon(
                  Icons.camera,
                  color: Theme.of(context).primaryColorLight,
                ),
                right: 0,
                bottom: 0,
                left: 40.0,
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
          value: _isFollowersPubliclyVisible,
          onChanged: (value) {
            setState(() {
              _isFollowersPubliclyVisible = value;
            });
          },
        ),
        SwitchListTile(
          title: Text('Show my followers publicly'),
          value: _isFollowingPubliclyVisible,
          onChanged: (value) {
            setState(() {
              _isFollowingPubliclyVisible = value;
            });
          },
        ),
        FutureBuilder(
          future: _saveSettingsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            return RaisedButton(
              onPressed: () {
                setState(() {
                  _saveSettingsFuture = save();
                });
              },
              child: Text('Submit'),
            );
          },
        ),
        SizedBox(height: 8),
      ],
    );
  }
}
