import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/models/user.dart';
import 'package:orbital2796_nusell/screens/posts.dart';
import 'package:orbital2796_nusell/screens/profile/avatar.dart';

class SellerProfileScreen extends StatefulWidget {
  final String sellerId;
  SellerProfileScreen({Key key, this.sellerId}) : super(key: key);

  @override
  _SellerProfileScreenState createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  NUSellUser user = NUSellUser();

  File newProfilePic;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.sellerId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          _readUserInfo();
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Center(child: CircularProgressIndicator());
          // }

          return Scaffold(
            appBar: AppBar(
              title: FutureBuilder(
                  future: _readUserInfo(),
                  builder: (context, snapshot) {
                    return Text("${user.username} 's Profile");
                  }),
              leading: BackButton(
                color: Colors.white,
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                    ),
                    child: FutureBuilder(
                        future: _readUserInfo(),
                        builder: (context, snapshot) {
                          print(user.username);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Avatar(
                                avatarUrl: user.avatarUrl,
                                onTap: () {},
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Username: ${user.username}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Email: ${user.email}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Phone number: ${user.phoneNumber}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          );
                        }),
                  ),
                  AllPostsScreen(
                    userId: widget.sellerId,
                  )
                ],
              ),
            ),

            //a collection of the three buttons
          );
        });
  }

  _readUserInfo() async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(widget.sellerId)
        .get();
    print(doc.data());
    user = NUSellUser.fromJson(doc.data());
    print(user.email);
  }
}
