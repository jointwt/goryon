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
    return Form(
      key: _formKey,
      child: Column(
        children: [
          RichText(
            text: TextSpan(
                text: 'We take all reports very seriously! ' +
                    ' If you are unsure about our community guidelines, please read the ',
                children: [
                  TextSpan(
                    text: 'Abuse Policy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ]),
          ),
          TextFormField(
            validator: FormValidators.requiredField,
            decoration: InputDecoration(labelText: 'Your name'),
          ),
          TextFormField(
            validator: FormValidators.requiredField,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: 'Your email address'),
          ),
          Text(
            'Please provide your name and email address so we may contact you ' +
                'for further information (if necessary) and so we can inform you of the outcome.',
          ),
          DropdownButton<String>(
            items: _abuseTypes,
            onChanged: (abuseValue) {
              setState(() {
                _abuseValue = abuseValue;
              });
            },
          ),
          TextFormField(
            validator: FormValidators.requiredField,
            initialValue: widget.initialMessage,
            decoration: InputDecoration(labelText: 'Message'),
          ),
          RichText(
            text: TextSpan(
                text: 'Please provide examples by linking to the content in question.' +
                    ' You may paste the /twt/xxxxxxx URLs or simply a list of the hashes.' +
                    ' Please also give a brief reason why you believe the community guidelines and therefore',
                children: [
                  TextSpan(
                    text: 'Abuse Policy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    children: [
                      TextSpan(text: ' is in direct violation'),
                    ],
                  ),
                ]),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_formKey.currentState.validate()) {}
        },
        label: Text('Submit'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: buildForm(),
          )
        ],
      ),
    );
  }
}
