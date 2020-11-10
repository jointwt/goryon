import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:goryon/viewmodels.dart';

import '../api.dart';
import '../form_validators.dart';
import '../models.dart';
import '../strings.dart';
import '../widgets/common_widgets.dart';
import '../widgets/image_picker.dart';

class NewTwt extends StatefulWidget {
  const NewTwt({Key key, this.initialText = ''}) : super(key: key);

  final String initialText;

  @override
  _NewTwtState createState() => _NewTwtState();
}

class _NewTwtState extends State<NewTwt> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText)
      ..buildTextSpan(withComposing: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SavePostButton(
        formKey: _formKey,
        textEditingController: _textController,
      ),
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<AppUser>(
          builder: (contxt, user, _) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar(imageUrl: user.twter.avatar.toString()),
              const SizedBox(width: 16.0),
              Flexible(
                child: NewTwtForm(
                  formKey: _formKey,
                  textEditingController: _textController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewTwtForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController textEditingController;

  const NewTwtForm({Key key, this.formKey, this.textEditingController})
      : super(key: key);

  @override
  _NewTwtFormState createState() => _NewTwtFormState();
}

class _NewTwtFormState extends State<NewTwtForm> {
  final _random = Random();
  final _scrollbarController = ScrollController();
  final _picker = ImagePicker();

  String _twtPrompt;
  Future _uploadImageFuture;

  @override
  void initState() {
    super.initState();
    _twtPrompt = _getTwtPrompt();
  }

  String _getTwtPrompt() {
    final prompts = context.read<AppStrings>().twtPromtpts;
    return prompts[_random.nextInt(prompts.length)];
  }

  void _surroundTextSelection(String left, String right) {
    final textEditingController = widget.textEditingController;
    final currentTextValue = textEditingController.value.text;
    final selection = textEditingController.selection;
    final middle = selection.textInside(currentTextValue);
    final newTextValue = selection.textBefore(currentTextValue) +
        '$left$middle$right' +
        selection.textAfter(currentTextValue);

    textEditingController.value = textEditingController.value.copyWith(
      text: newTextValue,
      selection: TextSelection.collapsed(
        offset: selection.baseOffset + left.length + middle.length,
      ),
    );
  }

  Future<void> _uploadImage() async {
    final textEditingController = widget.textEditingController;
    try {
      final pickedFile = await getImage(context, _picker);
      if (pickedFile == null) {
        return;
      }

      final imageURL = await context.read<Api>().uploadImage(pickedFile.path);
      textEditingController.value = textEditingController.value.copyWith(
        text: textEditingController.value.text + '![]($imageURL)',
      );
    } catch (_) {
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'An error has occurred while uploading an image. Please try again',
          ),
        ),
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Form(
          key: widget.formKey,
          child: TextFormField(
            validator: FormValidators.requiredField,
            autofocus: true,
            decoration: InputDecoration(
              hintText: _twtPrompt,
            ),
            maxLines: 8,
            controller: widget.textEditingController,
          ),
        ),
        SizedBox(
          height: 64,
          child: Scrollbar(
            controller: _scrollbarController,
            isAlwaysShown: true,
            child: ListView(
              controller: _scrollbarController,
              scrollDirection: Axis.horizontal,
              children: [
                IconButton(
                  tooltip: 'Bold',
                  icon: Icon(Icons.format_bold),
                  onPressed: () => _surroundTextSelection(
                    '**',
                    '**',
                  ),
                ),
                IconButton(
                  tooltip: 'Underline',
                  icon: Icon(Icons.format_italic),
                  onPressed: () => _surroundTextSelection(
                    '__',
                    '__',
                  ),
                ),
                IconButton(
                  tooltip: 'Code',
                  icon: Icon(Icons.code),
                  onPressed: () => _surroundTextSelection(
                    '```',
                    '```',
                  ),
                ),
                IconButton(
                  tooltip: 'Strikethrough',
                  icon: Icon(Icons.strikethrough_s_rounded),
                  onPressed: () => _surroundTextSelection(
                    '~~',
                    '~~',
                  ),
                ),
                IconButton(
                  tooltip: 'Link',
                  icon: Icon(Icons.link_sharp),
                  onPressed: () => _surroundTextSelection(
                    '[',
                    ']()',
                  ),
                ),
                IconButton(
                  tooltip: 'Image Link',
                  icon: Icon(Icons.image),
                  onPressed: () => _surroundTextSelection(
                    '![](https://',
                    ')',
                  ),
                ),
                FutureBuilder(
                  future: _uploadImageFuture,
                  builder: (context, snapshot) {
                    final isLoading =
                        snapshot.connectionState == ConnectionState.waiting;

                    void _onPressed() {
                      setState(() {
                        _uploadImageFuture = _uploadImage();
                      });
                    }

                    return IconButton(
                      tooltip: 'Upload image from camera',
                      icon: isLoading ? SizedSpinner() : Icon(Icons.camera_alt),
                      onPressed: isLoading ? null : _onPressed,
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SavePostButton extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController textEditingController;

  const SavePostButton({
    Key key,
    @required this.formKey,
    @required this.textEditingController,
  }) : super(key: key);

  @override
  _SavePostButtonState createState() => _SavePostButtonState();
}

class _SavePostButtonState extends State<SavePostButton> {
  Future _savePostFuture;

  void _submitPost() {
    if (!widget.formKey.currentState.validate()) return;
    setState(() {
      _savePostFuture = context
          .read<Api>()
          .savePost(widget.textEditingController.text)
          .then((value) => Navigator.pop(context, true));
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _savePostFuture,
      builder: (context, snapshot) {
        Widget label = const Text("Post");

        if (snapshot.connectionState == ConnectionState.waiting)
          label = SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          );

        return FloatingActionButton.extended(
          label: label,
          onPressed: _submitPost,
        );
      },
    );
  }
}
