import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/models/popUp.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:orbital2796_nusell/screens/profile/avatar.dart';
import 'package:orbital2796_nusell/screens/sellerProfile.dart';
import 'package:orbital2796_nusell/services/auth.dart';
import 'package:orbital2796_nusell/subProject/recommendation/backgroundTimer.dart';

class MyFollowersScreen extends StatefulWidget {
  const MyFollowersScreen({Key key}) : super(key: key);

  @override
  _MyFollowersScreenState createState() => _MyFollowersScreenState();
}

class _MyFollowersScreenState extends State<MyFollowersScreen> {
  CollectionReference follow = FirebaseFirestore.instance.collection('follow');
  final FirebaseFirestore db = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Followers'),
        leading: BackButton(
          onPressed: () {
            //Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ProfileScreen()));
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
            List usersFollowing = followDoc['followers'];
            if (usersFollowing.length == 0)
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('You have no followers yet!'),
              );
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
                                              confirmColor: Color.fromRGBO(
                                                  100, 170, 255, 1),
                                              confirmAction: () {
                                                db
                                                    .collection('follow')
                                                    .doc(AuthService()
                                                        .getCurrentUID())
                                                    .set({
                                                  'following':
                                                      FieldValue.arrayRemove(
                                                          user)
                                                }, SetOptions(merge: true));
                                                db
                                                    .collection('follow')
                                                    .doc(user)
                                                    .set({
                                                  'followers':
                                                      FieldValue.arrayRemove([
                                                    AuthService()
                                                        .getCurrentUID()
                                                  ])
                                                }, SetOptions(merge: true));
                                              },
                                            );
                                          });
                                    },
                                    child: StreamBuilder<DocumentSnapshot>(
                                        stream: db
                                            .collection('follow')
                                            .doc(AuthService().getCurrentUID())
                                            .snapshots(),
                                        builder: (context, snapshotForFollow) {
                                          if (!snapshotForFollow.hasData) {
                                            return CircularProgressIndicator();
                                          }
                                          Map<String, dynamic> mydoc =
                                              snapshotForFollow.data.data();

                                          List usersFollowing =
                                              mydoc['following'];
                                          bool following = false;
                                          for (var user1 in usersFollowing) {
                                            if (user == user1) following = true;
                                          }

                                          return GestureDetector(
                                              child: InkWell(
                                            onTap: () {
                                              if (following) {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return popUp(
                                                        title:
                                                            "Are you sure you want to unfollow?",
                                                        // subtitle: "You will need to sign in again to view your account!",
                                                        confirmText: "Unfollow",
                                                        confirmColor:
                                                            Color.fromRGBO(100,
                                                                170, 255, 1),
                                                        confirmAction: () {
                                                          db
                                                              .collection(
                                                                  'follow')
                                                              .doc(AuthService()
                                                                  .getCurrentUID())
                                                              .set(
                                                                  {
                                                                'following':
                                                                    FieldValue
                                                                        .arrayRemove([
                                                                  user
                                                                ])
                                                              },
                                                                  SetOptions(
                                                                      merge:
                                                                          true));
                                                          db
                                                              .collection(
                                                                  'follow')
                                                              .doc(user)
                                                              .set(
                                                                  {
                                                                'followers':
                                                                    FieldValue
                                                                        .arrayRemove([
                                                                  AuthService()
                                                                      .getCurrentUID()
                                                                ])
                                                              },
                                                                  SetOptions(
                                                                      merge:
                                                                          true));
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      );
                                                    });
                                              } else {
                                                db
                                                    .collection('follow')
                                                    .doc(AuthService()
                                                        .getCurrentUID())
                                                    .set({
                                                  'following':
                                                      FieldValue.arrayUnion(
                                                          [user])
                                                }, SetOptions(merge: true));
                                                db
                                                    .collection('follow')
                                                    .doc(user)
                                                    .set({
                                                  'followers':
                                                      FieldValue.arrayUnion([
                                                    AuthService()
                                                        .getCurrentUID()
                                                  ])
                                                }, SetOptions(merge: true));
                                                var timer = backgroundTimer(null);
                                                timer.updatePreference(null, null, user, 0);
                                              }
                                            },
                                            child: Container(
                                                margin:
                                                    EdgeInsets.only(left: 5),
                                                padding: EdgeInsets.only(
                                                    left: 5, right: 5),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Color.fromRGBO(
                                                            242, 195, 71, 1)),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.transparent),
                                                child: !following
                                                    ? Text(
                                                        "follow",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color:
                                                                Color.fromRGBO(
                                                                    242,
                                                                    195,
                                                                    71,
                                                                    1)),
                                                      )
                                                    : Text(
                                                        "following",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w300,
                                                            color:
                                                                Color.fromRGBO(
                                                                    242,
                                                                    195,
                                                                    71,
                                                                    1)),
                                                      )),
                                          ));
                                        })))
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
