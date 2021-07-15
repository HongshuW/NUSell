import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddAForumPostScreen extends StatefulWidget {
  AddAForumPostScreen({Key key}) : super(key: key);

  @override
  _AddAForumPostScreenState createState() => _AddAForumPostScreenState();
}

class _AddAForumPostScreenState extends State<AddAForumPostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //on pressed will return back to the home screen
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Publish a Forum Post',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white70,
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(249, 241, 219, 1),
          image: DecorationImage(
              image: AssetImage("assets/images/background.png"),
              fit: BoxFit.fill,
              alignment: Alignment.bottomRight
          ),
        ),
      ),
    );
  }
}