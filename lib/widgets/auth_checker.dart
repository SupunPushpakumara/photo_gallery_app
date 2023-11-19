import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:photo_gallery_app/screens/home_screen.dart';
import '../screens/login_screen.dart';

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

class CheckAuth extends StatefulWidget {
  const CheckAuth({super.key});

  @override
  CheckAuthState createState() => CheckAuthState();
}

class CheckAuthState extends State<CheckAuth> {
  bool isAuth = false;
  Future<bool>? loginCheckFuture;

  @override
  void initState() {
    super.initState();
    loginCheckFuture = _checkIfLoggedIn();
  }

  Future<bool> _checkIfLoggedIn() async {
    String? userId = await storage.read(key: "userid");
    if (userId != null) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    return FutureBuilder(
        future: loginCheckFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == true) {
              child = const HomeScreen();
            } else {
              child = const LoginScreen();
            }
          } else {
            child = Center(
              child: Image.asset('assets/images/logo.png'),
            );
          }

          return Scaffold(
            body: child,
          );
        });
  }
}
