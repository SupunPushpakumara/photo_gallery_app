import 'package:flutter/material.dart';

class DialogYesNo extends StatelessWidget {
  final String title;
  final String content;
  final Function handleYesClick;
  final Function handleNoClick;

  const DialogYesNo(
      {super.key,
      required this.title,
      required this.content,
      required this.handleYesClick,
      required this.handleNoClick});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          child: const Text("YES"),
          onPressed: () {
            handleYesClick();
          },
        ),
        TextButton(
          child: const Text("NO"),
          onPressed: () {
            handleNoClick();
          },
        ),
      ],
    );
  }
}
