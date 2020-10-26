import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

Future<PickedFile> getImage(
  BuildContext context,
  ImagePicker picker,
) async {
  switch (await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Choose photo'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, ImageSource.camera);
              },
              child: ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: Icon(Icons.add_a_photo),
                title: const Text('Take a photo'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, ImageSource.gallery);
              },
              child: ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: Icon(Icons.photo),
                title: const Text('Choose from gallery'),
              ),
            ),
          ],
        );
      })) {
    case ImageSource.gallery:
      return picker.getImage(source: ImageSource.gallery);
    case ImageSource.camera:
      return picker.getImage(source: ImageSource.camera);
  }

  return null;
}
