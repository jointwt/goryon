import 'package:flutter/material.dart';

import '../form_validators.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _taglineController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
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
      ),
    );
  }
}
