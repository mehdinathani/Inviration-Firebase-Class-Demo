import 'dart:io';

import 'package:image_picker/image_picker.dart';

Future<File?> selectImage() async {
  final imagePicker = ImagePicker();
  XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
  if (file != null) {
    return File(file.path);
  } else {
    return null;
  }
}
