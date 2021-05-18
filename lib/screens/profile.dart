import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/screens/home.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:orbital2796_nusell/screens/post.dart';

class ProfileScreen extends StatelessWidget {
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        //on pressed will log the user out to the log in page
        child: ElevatedButton(
          child: Text('Log Out'),
          onPressed: () {
            auth.signOut();
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()));
          },
        ),
      ),
      //a collection of the three buttons
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              heroTag: "home",
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              },
              child: Icon(Icons.house),
            ),
            FloatingActionButton(
              heroTag: "post",
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => PostScreen()));
              },
              child: Icon(Icons.add),
            ),
            FloatingActionButton(
              heroTag: "profile",
              onPressed: () {},
              child: Icon(Icons.person),
            )
          ],
        ),
      ),
    );
  }
}
