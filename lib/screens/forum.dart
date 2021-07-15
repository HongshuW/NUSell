import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/screens/addAForumPost.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:orbital2796_nusell/screens/home.dart';
import 'package:orbital2796_nusell/screens/myChats.dart';
import 'package:orbital2796_nusell/screens/post.dart';
import 'package:orbital2796_nusell/screens/profile.dart';

class ForumScreen extends StatefulWidget {
  ForumScreen({Key key}) : super(key: key);

  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forum"),
        automaticallyImplyLeading: false,
        actions: [
          // publish a forum post.
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddAForumPostScreen()));
              },
              icon: Icon(Icons.camera_alt))
        ],
      ),

      body: Center(
        child: Text("display forum posts"),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Color.fromRGBO(242, 195, 71, 1),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.house),
              label: "Home"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.art_track),
              label: "Forum"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              label: "Messages"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: "Sell"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile"
          ),
        ],
        onTap: (index) {
          if (auth.currentUser == null) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => LoginScreen()));
          } else {
            if (index == 0) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => HomeScreen()));
            } else if (index == 2) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => MyChatsScreen()));
            } else if (index == 3) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => PostScreen()));
            } else if (index == 4) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => ProfileScreen()));
            }
          }
        },
      ),
    );
  }
}