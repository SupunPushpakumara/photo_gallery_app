import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user_image.dart';
import './../const/const.dart' as apiconst;
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
final storage = FlutterSecureStorage();

// Function to upload an image to the server
class ImageHandler {
  static Future<dynamic> uploadImage(data) async {
    try {
      if (!await _checkInternet()) {
        throw ('No Internet');
      }

      // Retrieving the user token from secure storage
      String? token = await storage.read(key: "token");

      // Creating a POST request for image upload
      var postUri =
          Uri.parse(apiconst.kBaseUrl + apiconst.kImageUploadEndPoint);
      var request = http.MultipartRequest("POST", postUri);

      // Adding the image file to the request
      if (data['image'] != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'image', data['image'] != null ? data['image']!.path : '',
            contentType: MediaType('image', 'png')));
      }
      request.headers.addAll(
        {HttpHeaders.authorizationHeader: 'Bearer $token'},
      );

      // Sending the request and handling the response
      final response = request.send().then((response) async {
        if (response.statusCode == 201) {
          return 201;
        } else if (response.statusCode == 401) {
          throw ("401");
        } else {
          throw ('Server Error');
        }
      }).timeout(
        const Duration(seconds: 120),
        onTimeout: () {
          throw ('Server Timeout!');
        },
      );
      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  // Function to delete images from the server
  static Future<dynamic> deleteImages(imageIds) async {
    if (!await _checkInternet()) {
      throw ('No Internet');
    }
    String? token = await storage.read(key: "token");
    try {
      final response = await http.post(
          Uri.parse(apiconst.kBaseUrl +
              apiconst.kImageUploadEndPoint +
              apiconst.kImageDeleteEndPoint),
          body: {
            "imageIds": jsonEncode(imageIds),
          },
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $token',
          }).then((response) async {
        if (response.statusCode == 201) {
          return response.body;
        } else if (response.statusCode == 401) {
          throw ("401");
        } else {
          throw ('Server Error');
        }
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw ('Server Timeout!');
        },
      );
      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  // Function to get a list of user images from the server
  static Future<List<UserImage>> getImagesList() async {
    if (!await _checkInternet()) {
      throw ('No Internet');
    }
    String? token = await storage.read(key: "token");
    try {
      final response = await http.get(
          Uri.parse(apiconst.kBaseUrl + apiconst.kImageUploadEndPoint),
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $token',
          }).then((response) async {
        if (response.statusCode == 200) {
          return _decodeTankers(response.body);
        } else if (response.statusCode == 401) {
          throw ("401");
        } else {
          throw ('Server Error');
        }
      }).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw ('Server Timeout!');
        },
      );
      return response;
    } catch (error) {
      throw error.toString();
    }
  }

  // Function to decode the JSON response body into a list of UserImage objects
  static List<UserImage> _decodeTankers(String responseBody) {
    final body = json.decode(responseBody);
    final parsedBody = body.cast<Map<String, dynamic>>();
    return parsedBody
        .map<UserImage>((json) => UserImage.fromJson(json))
        .toList();
  }

  // Function to check internet connectivity
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
