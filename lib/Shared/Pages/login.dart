import 'package:city_watch/Organization/Home/org_home.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Home/landing_page.dart';
import '../../Reusables/components/square_tile.dart';
import '../../Reusables/footer/logo.dart';
import '../../Services/Authentication/auth.dart';
import '../../User/Home/user_home.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool _isObscure = true;
  bool visible = false;
  final _formkey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView( // Ensures scrolling for all content
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Text(
                    "Login",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent,
                      fontSize: 40,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          TextFormField(
                            cursorColor: Colors.black,
                            cursorWidth: 0.5,
                            controller: emailController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade100),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black54, width: 0.1),
                              ),
                              fillColor: Colors.grey.shade100,
                              filled: true,
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.deepPurple),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Email cannot be empty";
                              }
                              if (!RegExp(
                                  "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                  .hasMatch(value)) {
                                return "Please enter a valid email";
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            cursorColor: Colors.black,
                            cursorWidth: 0.5,
                            controller: passwordController,
                            obscureText: _isObscure,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(_isObscure ? Icons.visibility : Icons
                                    .visibility_off),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                },
                              ),
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.deepPurple),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey.shade100),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black54, width: 0.1),
                              ),
                              fillColor: Colors.grey.shade100,
                              filled: true,
                            ),
                            validator: (value) {
                              RegExp regex = RegExp(r'^.{6,}$');
                              if (value!.isEmpty) {
                                return "Password cannot be empty";
                              }
                              if (!regex.hasMatch(value)) {
                                return "Please enter a valid password with at least 6 characters";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 110),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        padding: const EdgeInsets.all(15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          visible = true;
                        });

                        if (_formkey.currentState!.validate()) {
                          try {
                            User? user = await _authService.signIn(
                                emailController.text, passwordController.text);
                            if (user != null) {
                              route(user); // Call route function
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Sign in failed'),
                                ),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Error occurred during sign in: $e'),
                              ),
                            );
                          }
                        }
                        setState(() {
                          visible = false;
                        });
                      },
                      child: const Center(
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: visible,
                    child: CircularProgressIndicator(
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.blueAccent,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a Member?',
                        style: TextStyle(color: Colors.grey[700],),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        child: const Text(
                          'Register Now',
                          style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LandingPage()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: FooterLogoTeal(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void route(User user) {
    if (kDebugMode) {
      print('Routing user with ID: ${user.uid}');
    }

    // Check vendors collection
    FirebaseFirestore.instance
        .collection('Organizations')
        .doc(user.uid)
        .get()
        .then((DocumentSnapshot OrgSnapshot) {
      if (kDebugMode) {
        print('Org snapshot exists: ${OrgSnapshot.exists}');
      }

      if (OrgSnapshot.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OrganizationHome()),
        );
      } else {
        // Check buyers collection
        FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .get()
            .then((DocumentSnapshot UserSnapshot) {
          if (kDebugMode) {
            print('User Snapshot exists: ${UserSnapshot.exists}');
          }

          if (UserSnapshot.exists) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserHome()),
            );
          } else {
            print('User does not exist in either collection');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('User does not exist in either collection')),
            );
          }
        })
            .catchError((error) {
          print("Error fetching User data: $error");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching User data: $error')),
          );
        });
      }
    })
        .catchError((error) {
      print("Error fetching Organization data: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching Organization data: $error')),
      );
    });
  }
}