import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/screens/addAForumPost.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:orbital2796_nusell/screens/home.dart';
import 'package:orbital2796_nusell/screens/myChats.dart';
import 'package:orbital2796_nusell/screens/post.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:orbital2796_nusell/screens/singleForumPost.dart';

class ForumScreen extends StatefulWidget {
  ForumScreen({Key key}) : super(key: key);

  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  String userId;

  // a list of document snapshots, each represents a post.
  List<DocumentSnapshot> forumPosts = [];
  // whether the page is loading.
  bool isLoading = false;
  // whether there are more posts in the database.
  bool hasMore = true;
  // number of posts on each load.
  int numPerPage = 10;
  DocumentSnapshot lastDoc;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getPosts();
    // load more when the end of the screen is reached.
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double criteria = 2;
      if (maxScroll - currentScroll < criteria) {
        getPosts();
      }
    });
  }

  // Load posts (depend on the current state) from database.
  getPosts() async {
    if (!hasMore || isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    if (lastDoc == null) {
      querySnapshot = await FirebaseFirestore.instance
          .collection("forumPosts")
          .orderBy("time", descending: true)
          .limit(numPerPage)
          .get();
    } else {
      querySnapshot = await FirebaseFirestore.instance
          .collection("posts")
          .orderBy("time", descending: true)
          .startAfterDocument(lastDoc)
          .limit(numPerPage)
          .get();
    }
    int len = querySnapshot.docs.length;
    if (len < numPerPage) {
      hasMore = false;
    }
    lastDoc = querySnapshot.docs[len - 1];
    forumPosts.addAll(querySnapshot.docs);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    userId = auth.currentUser.uid;
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.of(context).userGestureInProgress)
          return false;
        else
          return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Forum"),
          centerTitle: true,
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
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Container(
            color: Color.fromRGBO(195, 215, 223, 0.2),
            child: Column(
              children: [
                Expanded(
                    child: forumPosts.length == 0
                        ? Center(child: CircularProgressIndicator())
                        : ListView(
                            children: forumPosts.map<Widget>((post) {
                              return SingleForumPost(
                                  post: post, commented: false);
                            }).toList(),
                          ))
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          selectedItemColor: Color.fromRGBO(242, 195, 71, 1),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.house), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.art_track), label: "Forum"),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_rounded), label: "Messages"),
            BottomNavigationBarItem(icon: Icon(Icons.add), label: "Sell"),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          ],
          onTap: (index) {
            if (this.userId == null) {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()));
            } else {
              if (index == 0) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomeScreen()));
              } else if (index == 2) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => MyChatsScreen()));
              } else if (index == 3) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => PostScreen()));
              } else if (index == 4) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => ProfileScreen()));
              }
            }
          },
        ),
      ),
    );
  }
}
