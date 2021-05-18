import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orbital2796_nusell/screens/home.dart';
import 'package:orbital2796_nusell/screens/reset.dart';
import 'package:orbital2796_nusell/screens/verify.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email, _password;
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(hintText: 'Email'),
              onChanged: (value) {
                setState(() {
                  _email = value.trim();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(hintText: 'Password'),
              onChanged: (value) {
                setState(() {
                  _password = value.trim();
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () => _signin(_email, _password),
                child: Text('Sign In'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // background
                  onPrimary: Colors.white, // foreground
                ),
              ),
              ElevatedButton(
                onPressed: () => _signup(_email, _password),
                child: Text('Sign Up'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red, // background
                  onPrimary: Colors.white, // foreground
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
                  child: Text('Forgot Password?'))
            ],
          )
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

  _signup(String _email, String _password) async {
    try {
      await auth.createUserWithEmailAndPassword(
          email: _email, password: _password);

      //Success
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => VerifyScreen()));
    } on FirebaseAuthException catch (error) {
      print(error.message);
      Fluttertoast.showToast(msg: error.message, gravity: ToastGravity.TOP);
    }
  }
}
