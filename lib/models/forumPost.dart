import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class forumPost {
  String userID;
  String content;
  List<String> images;
  String docId = "";

  forumPost({this.userID, this.content, this.images});

  addAPost(BuildContext context) {
    var db = FirebaseFirestore.instance;
    CollectionReference posts = db.collection('forumPosts');
    CollectionReference myPosts = db.collection('myForumPosts');
    posts.add({
      'user': this.userID,
      'content': this.content,
      'time': DateTime.parse(DateTime.now().toString()),
      'images': this.images,
      'likes': 0,
      'commentNum': 0,
      'comments': FieldValue.arrayUnion([])
    }).then((docRef) {
      this.docId = docRef.id;
    }).then((value) => myPosts.doc(userID).set({
          'myForumPosts': FieldValue.arrayUnion([this.docId])
        }, SetOptions(merge: true)));
  }
}
