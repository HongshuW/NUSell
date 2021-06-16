import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/models/user.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:orbital2796_nusell/screens/productinfo.dart';

class MyShoppingCartsScreen extends StatefulWidget {
  final String userId;
  MyShoppingCartsScreen({Key key, this.userId}) : super(key: key);
  @override
  _MyShoppingCartsScreenState createState() => _MyShoppingCartsScreenState();
}

class _MyShoppingCartsScreenState extends State<MyShoppingCartsScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final FirebaseFirestore db = FirebaseFirestore.instance;

  final FirebaseStorage storage = FirebaseStorage.instance;

  CollectionReference users = FirebaseFirestore.instance.collection('users');

  NUSellUser user = NUSellUser();
  List<String> postAddresses = [];
  List postImages = [];
  String postProductName;
  int postPrice;

  getImage(imgArr) {
    var img;
    if (imgArr.isEmpty) {
      img =
          'https://firebasestorage.googleapis.com/v0/b/orbital-test-4e374.appspot.com/o/productpics%2Fdefault.png?alt=media&token=c1100242-206c-44d9-a51b-181937932156';
    } else {
      img = imgArr[0];
    }
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
      child: Image.network(
        img,
        fit: BoxFit.fitHeight,
        width: 60,
      ),
    );
  }

  _getMyPosts() async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await users.doc(widget.userId).get();
    user = NUSellUser.fromJson(doc.data());
    postAddresses = user.myCart;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Text("Loading");
          // }

          return Scaffold(
            appBar: AppBar(
              title: Text('My Shopping Cart'),
            ),
            body: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: [
                Container(
                    // padding: EdgeInsets.only(
                    //     left: 10, right: 10, top: 60, bottom: 90),
                    child: FutureBuilder<Object>(
                        future: _getMyPosts(),
                        builder: (context, snapshot) {
                          return ListView(
                            scrollDirection: Axis.vertical,
                            padding: const EdgeInsets.all(8),
                            shrinkWrap: true,
                            children: postAddresses.map((docId) {
                              return FutureBuilder<DocumentSnapshot>(
                                  future:
                                      db.collection("posts").doc(docId).get(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                    Map<String, dynamic> post =
                                        snapshot.data.data();
                                    return GestureDetector(
                                      onTap: () {
                                        if (auth.currentUser == null) {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginScreen()));
                                        } else {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProductInfoScreen(
                                                          product: docId)));
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: getImage(post['images']),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(30.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "${post['productName']}",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${post['price']}",
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              IconButton(
                                                  icon: Icon(Icons.delete),
                                                  onPressed: () {
                                                    users
                                                        .doc(widget.userId)
                                                        .update({
                                                      "shopping carts":
                                                          FieldValue
                                                              .arrayRemove(
                                                                  [docId])
                                                    });
                                                  })
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                            }).toList(),
                          );
                        })),
              ],
            ),
          );
        });
  }
}
