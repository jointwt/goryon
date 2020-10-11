import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api.dart';
import '../form_validators.dart';
import '../widgets/common_widgets.dart';

class Report extends StatefulWidget {
  static const String routePath = "/report";
  final String initialMessage;
  final String nick;
  final String url;
  final void Function() afterSubmit;

  const Report({
    Key key,
    this.initialMessage = '',
    @required this.afterSubmit,
    @required this.nick,
    @required this.url,
  }) : super(key: key);
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  Future _submitFuture;
  String _categoryValue = '';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _abuseTypes = [
    DropdownMenuItem(
      child: Text('Illegal activities'),
      value: 'illegal',
    ),
    DropdownMenuItem(
      child: Text('Harassment'),
      value: 'harassment',
    ),
    DropdownMenuItem(
      child: Text('Hate Speech'),
      value: 'hate',
    ),
    DropdownMenuItem(
      child: Text('Posting private information'),
      value: 'doxxing',
    ),
  ];

  Future<void> submitForm(BuildContext context) async {
    try {
      await context.read<Api>().submitReport(
            widget.nick,
            widget.url,
            _nameController.value.text,
            _emailController.value.text,
            _categoryValue,
            _messageController.value.text,
          );
      widget.afterSubmit();
    } catch (e) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit report'),
        ),
      );
      rethrow;
    }
  }

  TapGestureRecognizer buildAbusePageTap() {
    return TapGestureRecognizer()
      ..onTap = () {
        launch('https://twtxt.net/abuse');
      };
  }

  Widget buildForm() {
    return Builder(
      builder: (context) {
        return Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            children: [
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  text: 'We take all reports very seriously! ' +
                      ' If you are unsure about our community guidelines, please read the ',
                  children: [
                    TextSpan(
                        style: DefaultTextStyle.of(context).style.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                        recognizer: buildAbusePageTap(),
                        text: 'Abuse Policy',
                        children: [TextSpan(text: '.')]),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _nameController,
                  validator: FormValidators.requiredField,
                  decoration: InputDecoration(labelText: 'Your name'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _emailController,
                  validator: FormValidators.requiredField,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'Your email address'),
                ),
              ),
              Text(
                'Please provide your name and email address so we may contact you ' +
                    'for further information (if necessary) and so we can inform you of the outcome.',
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownFormField<String>(
                  context,
                  _abuseTypes,
                  isExpanded: true,
                  hint: Text('Select type of abuse...'),
                  onSaved: (newValue) {
                    setState(() {
                      _categoryValue = newValue;
                    });
                  },
                  validator: FormValidators.requiredField,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  controller: _messageController,
                  validator: FormValidators.requiredField,
                  keyboardType: TextInputType.multiline,
                  minLines: 2,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Message',
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    text: 'Please provide examples by linking to the content in question.' +
                        ' You may paste the /twt/xxxxxxx URLs or simply a list of the hashes.' +
                        ' Please also give a brief reason why you believe the community guidelines and therefore ',
                    children: [
                      TextSpan(
                        text: 'Abuse Policy',
                        style: DefaultTextStyle.of(context).style.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                        recognizer: buildAbusePageTap(),
                        children: [
                          TextSpan(
                            text: ' is in direct violation.',
                            style: DefaultTextStyle.of(context).style,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              FutureBuilder(
                future: _submitFuture,
                builder: (context, snapshot) {
                  final isLoading =
                      snapshot.connectionState == ConnectionState.waiting;
                  return RaisedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            if (!_formKey.currentState.validate()) {
                              return;
                            }

                            _formKey.currentState.save();
                            setState(() {
                              _submitFuture = submitForm(context);
                            });
                          },
                    child: isLoading ? SizedSpinner() : Text('Submit'),
                  );
                },
              ),
              SizedBox(height: 64),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Report abuse')),
      body: buildForm(),
    );
  }
}
