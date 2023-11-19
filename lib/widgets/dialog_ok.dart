import 'package:flutter/material.dart';

class DialogOk extends StatelessWidget {
  final String title;
  final String content;
  final Function handleOkClick;

  const DialogOk(
      {super.key,
      required this.title,
      required this.content,
      required this.handleOkClick});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          child: const Text("OK"),
          onPressed: () {
            handleOkClick();
          },
        ),
      ],
    );
  }
}
