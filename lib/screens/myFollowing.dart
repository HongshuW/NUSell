import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/models/popUp.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:orbital2796_nusell/screens/profile/avatar.dart';
import 'package:orbital2796_nusell/screens/sellerProfile.dart';
import 'package:orbital2796_nusell/services/auth.dart';

class MyFollowingScreen extends StatefulWidget {
  const MyFollowingScreen({Key key}) : super(key: key);

  @override
  _MyFollowingScreenState createState() => _MyFollowingScreenState();
}

class _MyFollowingScreenState extends State<MyFollowingScreen> {
  CollectionReference follow = FirebaseFirestore.instance.collection('follow');
  final FirebaseFirestore db = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Following'),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Navigator.of(context).pushReplacement(
            //     MaterialPageRoute(builder: (context) => ProfileScreen()));
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: follow.doc(AuthService().getCurrentUID()).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return CircularProgressIndicator();
            }
            Map<String, dynamic> followDoc = snapshot.data.data();
            List usersFollowing = followDoc['following'];
            return ListView(
              children: usersFollowing.map((user) {
                return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user)
                        .get(),
                    builder: (context2, snapshot2) {
                      if (!snapshot2.hasData || snapshot2.data == null)
                        return Center(child: CircularProgressIndicator());
                      Map<String, dynamic> userDoc = snapshot2.data.data();
                      if (snapshot2.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (userDoc == null) {
                        return Container();
                      }
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          SellerProfileScreen(sellerId: user)));
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Avatar(
                                      avatarUrl: userDoc['avatarUrl'],
                                      size: 25,
                                    ),
                                    // ClipRRect(
                                    //   borderRadius: BorderRadius.circular(60),
                                    //   child: CachedNetworkImage(
                                    //     imageUrl: userDoc['avatarUrl'],
                                    //     height: 50,
                                    //     width: 50,
                                    //     fit: BoxFit.fill,
                                    //     fadeInDuration: Duration.zero,
                                    //   ),
                                    // ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      userDoc['username'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            GestureDetector(
                                child: InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return popUp(
                                        title:
                                            "Are you sure you want to unfollow?",
                                        // subtitle: "You will need to sign in again to view your account!",
                                        confirmText: "Unfollow",
                                        confirmColor:
                                            Color.fromRGBO(100, 170, 255, 1),
                                        confirmAction: () {
                                          db
                                              .collection('follow')
                                              .doc(
                                                  AuthService().getCurrentUID())
                                              .set({
                                            'following':
                                                FieldValue.arrayRemove([user])
                                          }, SetOptions(merge: true));
                                          db
                                              .collection('follow')
                                              .doc(user)
                                              .set({
                                            'followers': FieldValue.arrayRemove(
                                                [AuthService().getCurrentUID()])
                                          }, SetOptions(merge: true));
                                          Navigator.of(context).pop();
                                        },
                                      );
                                    });
                              },
                              child: Container(
                                  margin: EdgeInsets.only(left: 5),
                                  padding: EdgeInsets.only(left: 5, right: 5),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.transparent),
                                  child: Text(
                                    "following",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black),
                                  )),
                            ))
                          ],
                        ),
                      );
                    });
              }).toList(),
            );
          }),
    );
  }
}
