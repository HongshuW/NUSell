import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/screens/login.dart';

class HomeScreen extends StatelessWidget {
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text('Log Out'),
          onPressed: () {
            auth.signOut();
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()));
          },
        ),
      ),
    );
  }
}
