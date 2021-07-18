import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/screens/singleForumPost.dart';
import 'package:orbital2796_nusell/subProject/custom_radio_grouped_button/custom_radio_grouped_button.dart';

class MyForumScreen extends StatefulWidget {
  MyForumScreen({Key key}) : super(key: key);
  @override
  _MyForumScreenState createState() => _MyForumScreenState();
}

class _MyForumScreenState extends State<MyForumScreen> {
  var auth = FirebaseAuth.instance;
  var db = FirebaseFirestore.instance;
  String user;
  String arrayDisplayed = "myForumPosts";
  List<dynamic> displayedPosts;

  // Display the list of posts as widgets.
  displayPosts() {
    List<Widget> posts = [];
    int len = displayedPosts.length;
    var i;
    // for each post, add a corresponding widget to the list `posts`.
    for (i = 0; i < len; i++) {
      String postID = displayedPosts[i];
      posts.add(StreamBuilder(
          stream: db.collection("forumPosts").doc(postID).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            return SingleForumPost(
                post: snapshot.data,
                commented: this.arrayDisplayed == "commented");
          })
      );
    }
    return posts;
  }

  @override
  Widget build(BuildContext context) {
    this.user = auth.currentUser.uid;
    return ListView(
      children: [
        Container(
          margin: EdgeInsets.only(top: 10, left: 20),
          child: CustomRadioButton(
            elevation: 0,
            autoWidth: true,
            absoluteZeroSpacing: true,
            defaultSelected: "myForumPosts",
            buttonLables: ["My posts", "Commented"],
            buttonValues: ["myForumPosts", "commented"],
            selectedColor: Color.fromRGBO(242, 195, 71, 1),
            unSelectedColor: Colors.white,
            radioButtonValue: (value) {
              setState(() {
                this.arrayDisplayed = value;
              });
            },
          ),
        ),

        FutureBuilder(
            future: db.collection("myForumPosts").doc(this.user).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              Map<String, dynamic> myForum = snapshot.data.data();
              if (myForum == null) {
                db.collection("myForumPosts").doc(this.user).set({
                  "commented": [], "myForumPosts": []
                });
                return Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 20),
                  child: Text(
                      this.arrayDisplayed == "myForumPosts"
                          ? "You haven't posted anything yet."
                          : "You haven't commented any post yet."
                  ),
                );
              }
              this.displayedPosts = myForum[this.arrayDisplayed];
              if (this.displayedPosts.length == 0) {
                return Container(
                  alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 20),
                    child: Text(
                        this.arrayDisplayed == "myForumPosts"
                            ? "You haven't posted anything yet."
                            : "You haven't commented any post yet."
                    ),
                );
              } else {
                return Column(children: displayPosts());
              }
            }),
      ],
    );
  }
}