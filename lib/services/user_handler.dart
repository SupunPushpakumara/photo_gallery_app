import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import './../const/const.dart' as apiconst;
import '../../models/user.dart';

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

class UserHandler {
  static Future<dynamic> signin(User user) async {
    try {
      if (!await _checkInternet()) {
        throw ('No Internet. Check Your Internet Connection.');
      }

      final response = await http
          .post(Uri.parse(apiconst.kBaseUrl + apiconst.kLoginEndPoint), body: {
        "email": user.email,
        "password": user.password,
      }).then((response) async {
        if (response.statusCode == 201) {
          User user = User.fromJson(jsonDecode(response.body)["payload"]);
          await storage.write(
              key: "token", value: jsonDecode(response.body)["access_token"]);
          await storage.write(
              key: "userid",
              value: jsonDecode(response.body)["payload"]["sub"].toString());
          await storage.write(
              key: "userRole",
              value: jsonDecode(response.body)["payload"]["role"].toString());
          return user;
        } else if (response.statusCode == 400 || response.statusCode == 401) {
          throw ('Please check your username and password');
        } else {
          throw ('Server Error');
        }
      }).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw ('Server Error');
        },
      );
      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  static Future<bool> _checkInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }
}
