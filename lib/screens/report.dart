import 'package:flutter/material.dart';
import 'package:goryon/form_validators.dart';

class Report extends StatefulWidget {
  final String initialMessage;

  const Report({Key key, this.initialMessage = ''}) : super(key: key);
  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  String _abuseValue = 'select';
  final _formKey = GlobalKey<FormState>();
  final _abuseTypes = [
    DropdownMenuItem(
      child: Text('Select type of abuse...'),
      value: 'select',
    ),
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
                      text: 'Abuse Policy',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  validator: FormValidators.requiredField,
                  decoration: InputDecoration(labelText: 'Your name'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
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
                child: DropdownButton(
                  isExpanded: true,
                  items: _abuseTypes,
                  value: _abuseValue,
                  onChanged: (abuseValue) {
                    setState(
                      () {
                        _abuseValue = abuseValue;
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextFormField(
                  validator: FormValidators.requiredField,
                  initialValue: widget.initialMessage,
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
                        children: [
                          TextSpan(
                            text: ' is in direct violation',
                            style: DefaultTextStyle.of(context).style,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: RaisedButton(
                  onPressed: () {},
                  child: Text('Submit'),
                ),
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
