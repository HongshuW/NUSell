import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/models/user.dart';
import 'package:orbital2796_nusell/screens/posts.dart';
import 'package:orbital2796_nusell/screens/profile/avatar.dart';
import 'package:orbital2796_nusell/screens/reviewsForUser.dart';
import 'package:orbital2796_nusell/screens/sellerPosts.dart';

class SellerProfileScreen extends StatefulWidget {
  final String sellerId;
  SellerProfileScreen({Key key, this.sellerId}) : super(key: key);

  @override
  _SellerProfileScreenState createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  Map<String, dynamic> user = new Map();

  File newProfilePic;
  bool showingPosts = true;

  @override
  Widget build(BuildContext context) {
    interactions(bool showingPosts) {
      if (showingPosts == true) {
        return SellerPostsScreen(
          userId: widget.sellerId,
        );
      } else {
        return ReviewsForUser(
          userId: widget.sellerId,
        );
      }
    }

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.sellerId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Center(child: CircularProgressIndicator());
          // }

          return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.sellerId)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                Map<String, dynamic> doc = snapshot.data.data();
                return Scaffold(
                  appBar: AppBar(
                    title: Text("${doc['username']} 's Profile"),
                    leading: BackButton(
                      color: Colors.black,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  body: ListView(
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                        ),
                        child: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(widget.sellerId)
                                .get(),
                            builder: (context, snapshot) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Avatar(
                                    avatarUrl: doc['avatarUrl'],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${doc['username']}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  //   child: Text(
                                  //     'Email: ${doc['email']}',
                                  //     style: TextStyle(fontSize: 16),
                                  //   ),
                                  // ),
                                  // Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  //   child: Text(
                                  //     'Phone number: ${doc['phoneNumber']}',
                                  //     style: TextStyle(fontSize: 16),
                                  //   ),
                                  // ),
                                ],
                              );
                            }),
                      ),
                      GestureDetector(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    showingPosts = true;
                                  });
                                },
                                child: Text(
                                  'posts',
                                  style: TextStyle(fontSize: 20),
                                )),
                            Container(height: 30, width: 1, color: Colors.grey),
                            InkWell(
                                onTap: () {
                                  setState(() {
                                    showingPosts = false;
                                  });
                                },
                                child: Text(
                                  'reviews',
                                  style: TextStyle(fontSize: 20),
                                )),
                          ],
                        ),
                      ),
                      interactions(showingPosts)
                    ],
                  ),

                  //a collection of the three buttons
                );
              });
        });
  }
}
