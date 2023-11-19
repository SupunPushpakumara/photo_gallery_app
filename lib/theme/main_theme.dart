import 'package:flutter/material.dart';

class MainTheme {
  static const Color primaryColor = Color(0xffdb1920);

  static const Color primaryColorDark = Color(0xffBE1E2D);

  static BoxDecoration buttonBoxDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(7.0),
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xffdb1920), Color(0xffbe1e2d)],
    ),
  );
}
