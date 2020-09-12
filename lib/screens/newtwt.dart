import 'dart:math';

import 'package:flutter/material.dart';
import 'package:goryon/viewmodels.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../api.dart';
import '../common_widgets.dart';
import '../models.dart';
import '../strings.dart';
import '../form_validators.dart';

class NewTwt extends StatefulWidget {
  const NewTwt({Key key, this.initialText = ''}) : super(key: key);

  final String initialText;

  @override
  _NewTwtState createState() => _NewTwtState();
}

class _NewTwtState extends State<NewTwt> {
  final _random = Random();
  final _formKey = GlobalKey<FormState>();
  final _scrollbarController = ScrollController();

  Future _savePostFuture;
  Future _uploadImageFromGalleryFuture;
  Future _uploadImageFromCameraFuture;
  TextEditingController _textController;
  String _twtPrompt;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _textController.buildTextSpan();
    _twtPrompt = _getTwtPrompt();
  }

  void _submitPost() {
    if (!_formKey.currentState.validate()) return;
    setState(() {
      _savePostFuture = context
          .read<Api>()
          .savePost(_textController.text)
          .then((value) => Navigator.pop(context, true));
    });
  }

  Future<void> _uploadImage(ImageSource imageSource) async {
    try {
      await context
          .read<NewTwtViewModel>()
          .prompUserForImageAndUpload(imageSource)
          .then((imageURL) {
        if (imageURL == null) return;
        _textController.value = _textController.value.copyWith(
          text: _textController.value.text + '![]($imageURL)',
        );
      });
    } on http.ClientException catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  String _getTwtPrompt() {
    final prompts = context.read<AppStrings>().twtPromtpts;
    return prompts[_random.nextInt(prompts.length)];
  }

  void _surroundTextSelection(String left, String right) {
    final currentTextValue = _textController.value.text;
    final selection = _textController.selection;
    final middle = selection.textInside(currentTextValue);
    final newTextValue = selection.textBefore(currentTextValue) +
        '$left$middle$right' +
        selection.textAfter(currentTextValue);

    _textController.value = _textController.value.copyWith(
      text: newTextValue,
      selection: TextSelection.collapsed(
        offset: selection.baseOffset + left.length + middle.length,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FutureBuilder(
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
          }),
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<User>(
          builder: (contxt, user, _) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Avatar(
                imageUrl: user.twter.avatar.toString(),
              ),
              const SizedBox(width: 16.0),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Form(
                      key: _formKey,
                      child: TextFormField(
                        validator: FormValidators.requiredField,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: _twtPrompt,
                        ),
                        maxLines: 8,
                        controller: _textController,
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
                                '[title](https://',
                                ')',
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
                              future: _uploadImageFromGalleryFuture,
                              builder: (context, snapshot) {
                                final isLoading = snapshot.connectionState ==
                                    ConnectionState.waiting;

                                void _onPressed() {
                                  setState(
                                    () {
                                      _uploadImageFromGalleryFuture =
                                          _uploadImage(
                                        ImageSource.gallery,
                                      );
                                    },
                                  );
                                }

                                return IconButton(
                                  tooltip: 'Upload image from gallery',
                                  icon: isLoading
                                      ? SizedSpinner()
                                      : Icon(Icons.photo_library),
                                  onPressed: isLoading ? null : _onPressed,
                                );
                              },
                            ),
                            FutureBuilder(
                              future: _uploadImageFromCameraFuture,
                              builder: (context, snapshot) {
                                final isLoading = snapshot.connectionState ==
                                    ConnectionState.waiting;

                                void _onPressed() {
                                  setState(
                                    () {
                                      _uploadImageFromCameraFuture =
                                          _uploadImage(
                                        ImageSource.camera,
                                      );
                                    },
                                  );
                                }

                                return IconButton(
                                  tooltip: 'Upload image from camera',
                                  icon: isLoading
                                      ? SizedSpinner()
                                      : Icon(Icons.camera_alt),
                                  onPressed: isLoading ? null : _onPressed,
                                );
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
