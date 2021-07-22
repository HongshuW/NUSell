import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/models/chat.dart';
import 'package:orbital2796_nusell/models/user.dart';
import 'package:orbital2796_nusell/screens/contactSeller.dart';
import 'package:orbital2796_nusell/screens/posts.dart';
import 'package:orbital2796_nusell/screens/profile/avatar.dart';
import 'package:orbital2796_nusell/screens/reviewsForUser.dart';
import 'package:orbital2796_nusell/screens/sellerPosts.dart';
import 'package:orbital2796_nusell/services/auth.dart';

class SellerProfileScreen extends StatefulWidget {
  final String sellerId;
  SellerProfileScreen({Key key, this.sellerId}) : super(key: key);

  @override
  _SellerProfileScreenState createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  Map<String, dynamic> user = new Map();

  File newProfilePic;
  bool showingPosts = true;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double newheight = height - padding.top - padding.bottom;
    interactions(bool showingPosts) {
      if (showingPosts == true) {
        return SellerPostsScreen(
          userId: widget.sellerId,
        );
      } else {
        return ReviewsForUser(
          userId: widget.sellerId,
          isForOwn: false,
        );
      }
    }

    String user = AuthService().getCurrentUID();
    String seller = widget.sellerId;
    Chat chat = new Chat([seller, user]);
    String docID;

    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.sellerId)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot> snapshotForUser) {
          if (snapshotForUser.hasError) {
            return Text('Something went wrong');
          }

          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Center(child: CircularProgressIndicator());
          // }
          if (snapshotForUser.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          Map<String, dynamic> doc = snapshotForUser.data.data();
          return Scaffold(
            appBar: AppBar(
              title: Text("${doc['username']} 's Profile"),
              leading: BackButton(
                color: Colors.black,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              actions: [
                Theme(
                    data: Theme.of(context).copyWith(
                        textTheme: TextTheme().apply(bodyColor: Colors.black),
                        dividerColor: Colors.white,
                        iconTheme: IconThemeData(color: Colors.white)),
                    child: IconButton(
                      icon: Icon(
                        Icons.chat_bubble_outline_rounded,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        if (seller.compareTo(user) < 0) {
                          docID = seller + "_" + user;
                        } else {
                          docID = user + "_" + seller;
                        }
                        db
                            .collection("chats")
                            .doc(docID)
                            .get()
                            .then((snapshot) => {
                                  if (!snapshot.exists)
                                    {
                                      db
                                          .collection("chats")
                                          .doc(docID)
                                          .set(chat.toMap()),
                                      db
                                          .collection("myChats")
                                          .doc(seller)
                                          .get()
                                          .then((sellerSnapshot) => {
                                                if (!sellerSnapshot.exists)
                                                  {
                                                    db
                                                        .collection("myChats")
                                                        .doc(seller)
                                                        .set({
                                                      "myChats": [docID]
                                                    })
                                                  }
                                                else
                                                  {
                                                    db
                                                        .collection("myChats")
                                                        .doc(seller)
                                                        .update({
                                                      "myChats":
                                                          FieldValue.arrayUnion(
                                                              [docID])
                                                    })
                                                  }
                                              }),
                                      db
                                          .collection("myChats")
                                          .doc(user)
                                          .get()
                                          .then((userSnapshot) => {
                                                if (!userSnapshot.exists)
                                                  {
                                                    db
                                                        .collection("myChats")
                                                        .doc(user)
                                                        .set({
                                                      "myChats": [docID]
                                                    })
                                                  }
                                                else
                                                  {
                                                    db
                                                        .collection("myChats")
                                                        .doc(user)
                                                        .update({
                                                      "myChats":
                                                          FieldValue.arrayUnion(
                                                              [docID])
                                                    })
                                                  }
                                              }),
                                    }
                                });
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ContactSellerScreen(
                                  chatID: docID,
                                  theOtherUserId: user,
                                  theOtherUserName: doc['username'],
                                )));
                      },
                    ))
              ],
            ),
            body: ListView(
              //crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: newheight / 4,
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
                              size: 50,
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
  }
}
