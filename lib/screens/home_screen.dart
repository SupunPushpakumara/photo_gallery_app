import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_gallery_app/helper/camera_helper.dart';
import 'package:photo_gallery_app/screens/login_screen.dart';
import 'package:photo_gallery_app/services/image_handler.dart';
import 'package:photo_gallery_app/screens/image_fullscreen_page.dart';
import '../theme/main_theme.dart';
import '../widgets/dialog_yes_no.dart';
import './../const/const.dart' as constants;
import '../models/user_image.dart';
import '../widgets/dialog_ok.dart';

AndroidOptions _getAndroidOptions() => const AndroidOptions(
      encryptedSharedPreferences: true,
    );
final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  bool _multipleSelectMode = false;
  List<int> selectedList = [];
  List<UserImage> imageList = [];
  String _userRole = '';
  DateTime? _currentBackPressTime;

  Future _handleImageSelect() async {
    final imageTemp = await CameraHelper.pickImage();
    _handleImageUpload({"image": imageTemp});
  }

  void _handleImageUpload(data) async {
    _showLoading();
    await ImageHandler.uploadImage(data).then((res) {
      _hideLoading();
      getImages();
    }).catchError((error) {
      _showErrorDialog(error);
    });
  }

  void _handleDelete(data) async {
    _showLoading();
    await ImageHandler.deleteImages(data).then((res) {
      setState(() {
        _isLoading = false;
        _multipleSelectMode = false;
        selectedList = [];
      });
      getImages();
    }).catchError((error) {
      _showErrorDialog(error);
    });
  }

  @override
  void initState() {
    getImages();
    super.initState();
  }

  void _showLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void _hideLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  void getImages() async {
    String? role = await storage.read(key: "userRole");
    setState(() {
      _userRole = role.toString();
    });
    _showLoading();
    await ImageHandler.getImagesList().then((list) {
      setState(() {
        imageList = list;
        _isLoading = false;
      });
    }).catchError((error) {
      _showErrorDialog(error);
    });
  }

  void _showErrorDialog(error) {
    _hideLoading();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogOk(
          title: "Error",
          content: error.toString(),
          handleOkClick: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _handleLogout() async {
    await storage.deleteAll().then((value) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  Future<bool> _handleBackPress() async {
    if (_multipleSelectMode) {
      setState(() {
        _multipleSelectMode = false;
        selectedList = [];
      });
      return false;
    }
    DateTime now = DateTime.now();
    if (_currentBackPressTime == null ||
        now.difference(_currentBackPressTime!) > const Duration(seconds: 2)) {
      _currentBackPressTime = now;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back button again to exit'),
        ),
      );
      return false;
    }
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
    return true;
  }

  void _handleDeleteImage(imageIds, callback) async {
    String message =
        "Do you want to delete the image${selectedList.length == 1 ? '' : 's'}";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogYesNo(
            title: "Are you sure?",
            content: message,
            handleYesClick: () {
              _handleDelete(imageIds);
              Navigator.pop(context);
              callback();
            },
            handleNoClick: () {
              Navigator.pop(context);
            });
      },
    );
  }

  _handleSelect(UserImage image) {
    final int id = image.id!.toInt();

    if (_multipleSelectMode) {
      setState(() {
        if (selectedList.contains(id)) {
          selectedList.remove(id);
        } else {
          selectedList.add(id);
        }
        if (selectedList.length == 0) {
          _multipleSelectMode = false;
        }
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ImageFullScreenPage(
                image: image,
                handleDelete: _handleDeleteImage,
                userRole: _userRole)),
      );
    }
  }

  _handleLongPress(int id) {
    setState(() {
      if (_userRole == constants.kAdminRole) {
        _multipleSelectMode = true;
        selectedList.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _userRole == constants.kAdminRole
          ? FloatingActionButton(
              backgroundColor: MainTheme.primaryColor,
              onPressed: _handleImageSelect,
              child: const Icon(Icons.add))
          : null,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          if (_multipleSelectMode)
            IconButton(
              onPressed: () {
                _handleDeleteImage(selectedList, () {});
              },
              icon: const Icon(Icons.delete),
            ),
          PopupMenuButton<String>(
            onSelected: (String choice) {
              if (choice == constants.kMenuLogOut) {
                _handleLogout();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: constants.kMenuLogOut,
                child: Text('Logout'),
              ),
            ],
          ),
        ],
        backgroundColor: MainTheme.primaryColor,
        title: const Text(
          "Gallery",
        ),
      ),
      body: WillPopScope(
        onWillPop: _handleBackPress,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 10.0),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      for (var i = 0; i < imageList.length; i++)
                        InkWell(
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selectedList.contains(imageList[i].id)
                                    ? MainTheme.primaryColor
                                    : Colors.transparent,
                                width: 3.0,
                              ),
                              image: DecorationImage(
                                image: NetworkImage(
                                  constants.kBaseUrl +
                                      imageList[i].imagePath.toString(),
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          onTap: () => {_handleSelect(imageList[i])},
                          onLongPress: () =>
                              {_handleLongPress(imageList[i].id!.toInt())},
                        ),
                    ],
                  ),
                ),
              ),
            ),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                    color: MainTheme.primaryColor,
                  ))
                : const SizedBox(),
            _isLoading
                ? Container(
                    color: const Color.fromRGBO(0, 0, 0, 0.4),
                  )
                : const SizedBox()
          ],
        ),
      ),
    );
  }
}
