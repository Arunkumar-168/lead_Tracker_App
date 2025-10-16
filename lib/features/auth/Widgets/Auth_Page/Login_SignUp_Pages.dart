import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracker_app/features/auth/FireBase_Auth_Helpher.dart';
import 'package:tracker_app/features/auth/Validator.dart';
import 'package:tracker_app/features/leads/Lead_Page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _loginFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();
  final _emailLoginController = TextEditingController();
  final _passwordLoginController = TextEditingController();
  final _nameSignUpController = TextEditingController();
  final _emailSignUpController = TextEditingController();
  final _passwordSignUpController = TextEditingController();
  final _confirmPasswordSignUpController = TextEditingController();

  final _focusName = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
      if (isLogin) {
        _signUpFormKey.currentState?.reset();
        _nameSignUpController.clear();
        _emailSignUpController.clear();
        _passwordLoginController.clear();
        _confirmPasswordSignUpController.clear();
      } else {
        _loginFormKey.currentState?.reset();
        _emailLoginController.clear();
        _passwordLoginController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 90),
                  const Text(
                    'Leads Tracker App',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            isLogin ? "Login" : "Sign Up",
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple),
                          ),
                          const SizedBox(height: 10),

                          //Login Form
                          if (isLogin)
                            Form(
                              key: _loginFormKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _emailLoginController,
                                    focusNode: _focusEmail,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Email is required";
                                      }
                                      return Validator.validateEmail(
                                          email: value);
                                    },
                                    decoration: _inputDecoration("Email"),
                                  ),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    controller: _passwordLoginController,
                                    focusNode: _focusPassword,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Password is required";
                                      }
                                      return Validator.validatePassword(
                                          password: value);
                                    },
                                    decoration: _inputDecoration("Password"),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                      minimumSize:
                                          const Size(double.infinity, 50),
                                    ),
                                    onPressed: () async {
                                      if (_loginFormKey.currentState!.validate()) {
                                        try {
                                          User? user = await FirebaseAuthHelper.signInUsingEmailPassword(
                                            email: _emailLoginController.text.trim(),
                                            password: _passwordLoginController.text.trim(),
                                          );
                                          if (user != null) {
                                            Get.offAll(() => LeadPage(), arguments: {'user': user});
                                            Get.snackbar(
                                              'Login Successful',
                                              'You have logged in successfully!',
                                              snackPosition: SnackPosition.BOTTOM,
                                              backgroundColor: Colors.green,
                                              colorText: Colors.white,
                                            );
                                          }
                                        } on FirebaseAuthException catch (e) {
                                          String message;
                                          if (e.code == 'user not found') {
                                            message = 'Please check your email.';
                                          } else if (e.code == 'wrong password') {
                                            message = 'Incorrect password';
                                          } else {
                                            message = e.message ?? 'Login failed';
                                          }
                                          // Show dialog
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Login Failed'),
                                              content: Text(message),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      }
                                    },

                                    child: const Text(
                                      "Login",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          //sign up Form
                          if (!isLogin)
                            Form(
                              key: _signUpFormKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _nameSignUpController,
                                    focusNode: _focusName,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Name is required";
                                      }
                                      return Validator.validateName(
                                          name: value);
                                    },
                                    decoration: _inputDecoration("Name"),
                                  ),
                                  const SizedBox(height: 15),
                                  TextFormField(
                                    controller: _emailSignUpController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Email is required";
                                      }
                                      return Validator.validateEmail(
                                          email: value);
                                    },
                                    decoration: _inputDecoration("Email"),
                                  ),
                                  const SizedBox(height: 15),
                                  TextFormField(
                                    controller: _passwordSignUpController,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return "Password is required";
                                      }
                                      return Validator.validatePassword(
                                          password: value);
                                    },
                                    decoration: _inputDecoration("Password"),
                                  ),
                                  const SizedBox(height: 15),
                                  TextFormField(
                                    controller:
                                        _confirmPasswordSignUpController,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please confirm password';
                                      }
                                      if (value !=
                                          _passwordSignUpController.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                    decoration:
                                        _inputDecoration("Confirm Password"),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                      minimumSize:
                                          const Size(double.infinity, 50),
                                    ),
                                    onPressed: () async {
                                      if (_signUpFormKey.currentState!
                                          .validate()) {
                                        try {
                                          User? user = await FirebaseAuthHelper
                                              .registerUsingEmailPassword(
                                            name: _nameSignUpController.text
                                                .trim(),
                                            email: _emailSignUpController.text
                                                .trim(),
                                            password: _passwordSignUpController
                                                .text
                                                .trim(),
                                          );

                                          if (user != null) {
                                            Get.snackbar(
                                              'Signup Successful',
                                              'Account created successfully!',
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                              backgroundColor: Colors.green,
                                              colorText: Colors.white,
                                            );
                                            Future.delayed(
                                                const Duration(seconds: 1), () {
                                              Get.offAll(
                                                  () => const LoginPage());
                                            });
                                          }
                                        } on FirebaseAuthException catch (e) {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title:
                                                  const Text('Signup Failed'),
                                              content:
                                                  Text(e.message ?? 'Error'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text(
                                      "Sign Up",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: toggleForm,
                            child: RichText(
                              text: TextSpan(
                                text: isLogin
                                    ? "Don't have an account? "
                                    : "Already have an account? ",
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: isLogin ? "Sign Up" : "Login",
                                    style: const TextStyle(
                                        color: Colors.purple,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.purple, width: 1.5),
      ),
    );
  }
}
