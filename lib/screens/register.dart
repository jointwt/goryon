import 'package:flutter/material.dart';
import 'package:goryon/form_validators.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../api.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                SizedBox(height: 16),
                TextFormField(
                  validator: FormValidators.requiredField,
                  controller: _usernameTextController,
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
                  validator: FormValidators.requiredField,
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
                TextFormField(
                  autofillHints: [AutofillHints.url],
                  validator: FormValidators.requiredField,
                  controller: _podURLController,
                  decoration: InputDecoration(
                    labelText: 'Pod URL',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                ),
                SizedBox(height: 32),
                FutureBuilder(
                  future: _registerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return RaisedButton(
                      onPressed: () {
                        if (!_formKey.currentState.validate()) return;

                        setState(() {
                          _registerFuture = _handleRegister(context);
                        });
                      },
                      child: const Text('Register'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
