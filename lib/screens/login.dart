import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/models/user.dart';
import 'package:orbital2796_nusell/screens/reset.dart';
import 'package:orbital2796_nusell/screens/signup.dart';
import 'package:orbital2796_nusell/services/auth.dart';

NUSellUser currentUser;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email, _password;
  TextEditingController password = TextEditingController();

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
      body: ListView(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () =>
                    AuthService().signin(_email, _password, context),
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
              Positioned(child: Image.asset(
                  'assets/images/wavingLion.png',
                width: MediaQuery.of(context).size.width * 0.7
              ))
            ],
          ),
        ],
      ),
    );
  }
}
