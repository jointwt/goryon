import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:goryon/form_validators.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _communityGuidelineToggle = false;
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _passwordTextController = TextEditingController();
  final _podURLController = TextEditingController();
  Future _registerFuture;
  final _usernameTextController = TextEditingController();

  Future _handleRegister(BuildContext context) async {
    try {
      await context.read<Api>().register(
            _podURLController.text,
            _usernameTextController.text,
            _passwordTextController.text,
            _podURLController.text,
          );
      Navigator.pop(context, true);
    } catch (e) {
      var message = 'Unexpected error';
      if (e is http.ClientException) {
        message = e.message;
      }
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(message)));
      rethrow;
    }
  }

  TapGestureRecognizer buildCommunityGuidelinesToggle() {
    return TapGestureRecognizer()
      ..onTap = () {
        launch('https://twtxt.net/abuse');
      };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Builder(
        builder: (context) {
          return AutofillGroup(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  SizedBox(height: 16),
                  TextFormField(
                    validator: FormValidators.requiredField,
                    controller: _usernameTextController,
                    keyboardType: TextInputType.name,
                    autofillHints: [AutofillHints.username],
                    decoration: InputDecoration(
                      labelText: 'Username',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  TextFormField(
                    validator: FormValidators.requiredField,
                    controller: _passwordTextController,
                    autofillHints: [AutofillHints.password],
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  TextFormField(
                    autofillHints: [AutofillHints.email],
                    keyboardType: TextInputType.emailAddress,
                    validator: FormValidators.requiredField,
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      helperText:
                          'We\'ll never share your email address. Used for password recovery only.',
                      helperMaxLines: 100,
                    ),
                  ),
                  TextFormField(
                    autofillHints: [AutofillHints.url],
                    validator: FormValidators.requiredField,
                    keyboardType: TextInputType.url,
                    controller: _podURLController,
                    decoration: InputDecoration(
                      labelText: 'Pod URL',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            text: 'I agree to abide by the ',
                            children: [
                              TextSpan(
                                text: 'Community Guidelines',
                                recognizer: buildCommunityGuidelinesToggle(),
                                style: TextStyle(color: Colors.blue),
                                children: [
                                  TextSpan(text: '.'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Switch(
                        value: _communityGuidelineToggle,
                        onChanged: (newValue) {
                          setState(() {
                            _communityGuidelineToggle = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 32),
                  FutureBuilder(
                    future: _registerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      return RaisedButton(
                        onPressed: !_communityGuidelineToggle
                            ? null
                            : () {
                                if (!_formKey.currentState.validate()) return;

                                setState(() {
                                  _registerFuture = _handleRegister(context);
                                });
                              },
                        child: const Text('Register'),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      text:
                          'By registering an account on twtxt.net you agree to abide by the Community Guidelines set out in the',
                      children: [
                        TextSpan(
                          style: TextStyle(color: Colors.blue),
                          text: ' Abuse Policy',
                          recognizer: buildCommunityGuidelinesToggle(),
                          children: [
                            TextSpan(text: '.'),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
