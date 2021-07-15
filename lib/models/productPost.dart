import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orbital2796_nusell/screens/profile.dart';

class productPost {
  String userId;
  String productName;
  String description;
  double price;
  String docId;
  String location;
  String category;
  double sellerScore;

  productPost({
    this.userId,
    this.productName,
    this.description,
    this.price,
    this.category,
    this.location,
    this.sellerScore
  });

  addAPost(BuildContext context) {
    var db = FirebaseFirestore.instance;
    CollectionReference posts = db.collection('posts');
    CollectionReference myPosts = db.collection('myPosts');
    posts.add({
      'user': this.userId,
      'productName': this.productName,
      'description': this.description,
      'category': this.category,
      'price': this.price,
      'location': this.location,
      'images': [],
      'time': DateTime.parse(DateTime.now().toString()),
      'searchKey': this.productName.substring(0, 1).toLowerCase(),
      'nameForSearch': this.productName.toLowerCase().trim() +
          this.description.toLowerCase().trim(),
      'sellerScore': this.sellerScore,
      'status': "Selling"
    })
        .then((docRef) {
          this.docId = docRef.id;
          posts.doc(this.docId).update({"productId": this.docId});
        })
        .then((value) => myPosts.doc(userId).set({
            'myPosts': FieldValue.arrayUnion([this.docId])
            }, SetOptions(merge: true)))
        .then((value) => Fluttertoast.showToast(
            msg: 'You have added a post successfully!',
            gravity: ToastGravity.CENTER))
        .then((value) => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ProfileScreen())));
  }
}