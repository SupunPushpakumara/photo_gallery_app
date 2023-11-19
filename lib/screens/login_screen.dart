import 'package:flutter/material.dart';
import 'package:photo_gallery_app/screens/home_screen.dart';
import 'package:photo_gallery_app/theme/main_theme.dart';
import '../models/user.dart';
import '../services/user_handler.dart';
import '../widgets/dialog_ok.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameInputController =
      TextEditingController();
  final TextEditingController _passwordInputController =
      TextEditingController();
  User? currentuser;
  bool isLoading = false;
  bool passwordVisible = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  void _signin(User user) async {
    setState(() {
      isLoading = true;
    });
    await UserHandler.signin(user).then((token) {
      if (token != null && token != '') {
        setState(() {
          isLoading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return DialogOk(
            title: "Error",
            content: error,
            handleOkClick: () {
              Navigator.pop(context);
            },
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          WillPopScope(
            onWillPop: () async => false,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Expanded(
                    flex: 1,
                    child: SizedBox(),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      height: 100.0,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ),
                  Expanded(
                      flex: 5,
                      child: ListView(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            child: TextFormField(
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 20.0),
                                labelText: "Email",
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 1,
                                      color: Colors.grey), //<-- SEE HERE
                                  borderRadius: BorderRadius.circular(7.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                }
                                return null;
                              },
                              controller: _usernameInputController,
                            ),
                          ),
                          SizedBox(height: size.height * 0.03),
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 40),
                            child: TextFormField(
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 20.0),
                                labelText: "Password",
                                border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      width: 1,
                                      color: Colors.grey), //<-- SEE HERE
                                  borderRadius: BorderRadius.circular(7.0),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(!passwordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () {
                                    setState(
                                      () {
                                        passwordVisible = !passwordVisible;
                                      },
                                    );
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                return null;
                              },
                              obscureText: !passwordVisible,
                              controller: _passwordInputController,
                            ),
                          ),
                          // Container(
                          //   alignment: Alignment.centerRight,
                          //   margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                          //   child: Text(
                          //     "Forgot your password?",
                          //     style: TextStyle(fontSize: 12, color: Color(0XFF2661FA)),
                          //   ),
                          // ),
                          SizedBox(height: size.height * 0.05),
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  User user = User();
                                  user.email = _usernameInputController.text;
                                  user.password = _passwordInputController.text;
                                  _signin(user);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(80.0),
                                ),
                                padding: const EdgeInsets.all(0),
                              ),
                              child: Container(
                                alignment: Alignment.center,
                                height: 50.0,
                                width: size.width,
                                decoration: MainTheme.buttonBoxDecoration,
                                padding: const EdgeInsets.all(0),
                                child: const Text(
                                  "LOGIN",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ))
                ],
              ),
            ),
          ),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  color: MainTheme.primaryColor,
                ))
              : const SizedBox(),
          isLoading
              ? Container(
                  color: const Color.fromRGBO(0, 0, 0, 0.4),
                )
              : const SizedBox()
        ],
      ),
    );
  }
}
