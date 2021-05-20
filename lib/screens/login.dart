import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orbital2796_nusell/screens/home.dart';
import 'package:orbital2796_nusell/screens/reset.dart';
import 'package:orbital2796_nusell/screens/signup.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email, _password, _confirmPassword;
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1.0),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(252, 228, 70, 1),
        title: Text(
          'NUSell',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(hintText: 'Email'),
              onChanged: (value) {
                setState(() {
                  _email = value.trim();
                });
              },
              validator: (String value) {
                if (value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(hintText: 'Password'),
              onChanged: (value) {
                setState(() {
                  _password = value.trim();
                });
              },
              validator: (String value) {
                if (value.isEmpty) {
                  return 'Please enter password';
                }

                return null;
              },
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: TextFormField(
          //     controller: confirmPassword,
          //     validator: (String value) {
          //       if (value.isEmpty) {
          //         return 'Please re-enter password';
          //       }

          //       if (confirmPassword.text != _password) {
          //         return 'Password does not match';
          //       }

          //       return null;
          //     },
          //     obscureText: true,
          //     decoration: InputDecoration(hintText: 'Confirm Password'),
          //     onChanged: (value) {
          //       setState(() {
          //         _confirmPassword = value.trim();
          //       });
          //     },
          //   ),
          // ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () => _signin(_email, _password),
                child: Text('Sign In'),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(242, 195, 71, 1), // background
                  onPrimary: Colors.black, // foreground
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => SignupScreen()));
                },
                child: Text('Sign Up'),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(242, 195, 71, 1), // background
                  onPrimary: Colors.black, // foreground
                ),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ResetScreen())),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(fontSize: 16),
                  ))
            ],
          ),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(child: Image.asset('assets/images/wavingLion.png'))
            ],
          ),
        ],
      ),
    );
  }

  _signin(String email, String _password) async {
    try {
      await auth.signInWithEmailAndPassword(email: _email, password: _password);

      //Success
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseAuthException catch (error) {
      print(error.message);
      Fluttertoast.showToast(msg: error.message, gravity: ToastGravity.TOP);
    }
  }
}
