import 'package:flutter/material.dart';
import 'package:photo_gallery_app/models/user_image.dart';
import 'package:photo_gallery_app/theme/main_theme.dart';
import './../const/const.dart' as constants;

class ImageFullScreenPage extends StatelessWidget {
  final UserImage image;
  final Function handleDelete;
  final String userRole;
  const ImageFullScreenPage(
      {Key? key,
      required this.image,
      required this.handleDelete,
      required this.userRole})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar with delete button for admin users
      appBar: AppBar(
        actions: [
          if (userRole == constants.kAdminRole)
            IconButton(
                // Handling delete action and popping the screen
                onPressed: () {
                  handleDelete([image.id!.toInt()], () {
                    Navigator.pop(context);
                  });
                },
                icon: const Icon(Icons.delete))
        ],
        backgroundColor: MainTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        // Displaying the image using its path
        child: Image.network(
          constants.kBaseUrl + image.imagePath.toString(),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
