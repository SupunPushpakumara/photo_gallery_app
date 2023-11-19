import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class CameraHelper {
  static Future<dynamic> pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
          source: ImageSource.gallery, maxHeight: 800, maxWidth: 800);
      if (image == null) return;
      final imageTemp = File(image.path);
      return imageTemp;
    } on PlatformException {
      throw ('Failed to pick image');
    }
  }
}
