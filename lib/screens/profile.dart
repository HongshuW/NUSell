import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orbital2796_nusell/screens/addAForumPost.dart';
import 'package:orbital2796_nusell/screens/forum.dart';
import 'package:orbital2796_nusell/screens/myFollowers.dart';
import 'package:orbital2796_nusell/screens/myFollowing.dart';
import 'package:orbital2796_nusell/screens/myForum.dart';
import 'package:orbital2796_nusell/screens/offersMade.dart';
import 'package:orbital2796_nusell/screens/offersReceived.dart';
import 'package:orbital2796_nusell/screens/post.dart';
import 'package:orbital2796_nusell/screens/reviewsForUser.dart';
import 'package:orbital2796_nusell/screens/settings.dart';
import 'package:orbital2796_nusell/screens/transactionHistory.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:orbital2796_nusell/models/user.dart';
import 'package:orbital2796_nusell/screens/home.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:orbital2796_nusell/screens/posts.dart';
import 'package:orbital2796_nusell/screens/myChats.dart';
import 'package:orbital2796_nusell/screens/profile/avatar.dart';
import 'package:orbital2796_nusell/services/auth.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Stream<DocumentSnapshot> _userStream = FirebaseFirestore.instance
      .collection('users')
      .doc(AuthService().getCurrentUID())
      .snapshots();
  NUSellUser user = NUSellUser();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  File newProfilePic;

  @override
  Widget build(BuildContext context) {
    // bool showingPosts = true;
    // interactions(bool showingPosts) {
    //   if (showingPosts == true) {
    //     return
    //   }
    // }
    double height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    double newheight = height - padding.top - padding.bottom;
    return StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          Map<String, dynamic> doc = snapshot.data.data();
          return WillPopScope(
            onWillPop: () async {
              if (Navigator.of(context).userGestureInProgress)
                return false;
              else
                return true;
            },
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: Text('Your Profile'),

                // leading: BackButton(
                //   color: Colors.black,
                //   onPressed: () {
                //     Navigator.of(context).push(MaterialPageRoute(
                //         builder: (context) => HomeScreen()));
                //   },
                // ),
                actions: [
                  Theme(
                      data: Theme.of(context).copyWith(
                          textTheme: TextTheme().apply(bodyColor: Colors.black),
                          dividerColor: Colors.white,
                          iconTheme: IconThemeData(color: Colors.white)),
                      child: IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: Colors.black87,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SettingsScreen()));
                        },
                      )
                      // PopupMenuButton<int>(
                      //   color: Colors.black,
                      //   itemBuilder: (context) => [
                      //     PopupMenuItem<int>(
                      //         value: 0,
                      //         child: Row(
                      //           children: [
                      //             Icon(
                      //               Icons.settings,
                      //               color: Colors.grey,
                      //             ),
                      //             const SizedBox(
                      //               width: 7,
                      //             ),
                      //             Text("Settings"),
                      //           ],
                      //         )),
                      //     // PopupMenuItem<int>(
                      //     //     value: 1, child: Text("Reset password")),
                      //     //PopupMenuDivider(),
                      //     PopupMenuItem<int>(
                      //         value: 2,
                      //         child: Row(
                      //           children: [
                      //             Icon(
                      //               Icons.logout,
                      //               color: Colors.red,
                      //             ),
                      //             const SizedBox(
                      //               width: 7,
                      //             ),
                      //             Text("Logout")
                      //           ],
                      //         )),
                      //   ],
                      //   onSelected: (item) => SelectedItem(context, item),
                      // ),
                      ),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: newheight / 2.5,
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
                              .doc(FirebaseAuth.instance.currentUser.uid)
                              .get(),
                          builder: (context, snapshot) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Avatar(
                                  avatarUrl: doc['avatarUrl'],
                                  onTap: () {},
                                  size: 50,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Username: ${doc['username']}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Email: ${auth.currentUser.email}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                doc['phoneNumber'] == null ||
                                        doc['phoneNumber'] == ""
                                    ? Container()
                                    : Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Phone number: ${doc['phoneNumber']}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                StreamBuilder<DocumentSnapshot>(
                                    stream: db
                                        .collection('follow')
                                        .doc(AuthService().getCurrentUID())
                                        .snapshots(),
                                    builder: (context, snapshotForFollow) {
                                      if (!snapshot.hasData ||
                                          snapshotForFollow.connectionState ==
                                              ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      }
                                      Map<String, dynamic> followDoc =
                                          snapshotForFollow.data.data();
                                      List usersFollowing =
                                          followDoc['following'];
                                      List followers = followDoc['followers'];
                                      return GestureDetector(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            MyFollowingScreen()));
                                              },
                                              child: Column(
                                                children: [
                                                  Text(
                                                      '${usersFollowing.length}'),
                                                  Text('Following')
                                                ],
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            MyFollowersScreen()));
                                              },
                                              child: Column(
                                                children: [
                                                  Text('${followers.length}'),
                                                  Text('Followers')
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    })
                              ],
                            );
                          }),
                    ),
                    GestureDetector(
                      child: Column(
                        //scrollDirection: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          rowWidget(
                            context,
                            'product posts',
                            IconButton(
                              icon: Icon(Icons.arrow_forward_ios_rounded),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            myPosts(context)));
                              },
                            ),
                          ),
                          rowWidget(
                            context,
                            'reviews',
                            IconButton(
                              icon: Icon(Icons.arrow_forward_ios_rounded),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            myReviews(context)));
                              },
                            ),
                          ),
                          rowWidget(
                            context,
                            'offers received',
                            IconButton(
                              icon: Icon(Icons.arrow_forward_ios_rounded),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OffersReceivedScreen()));
                              },
                            ),
                          ),
                          rowWidget(
                            context,
                            'offers made',
                            IconButton(
                              icon: Icon(Icons.arrow_forward_ios_rounded),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OffersMadeScreen()));
                              },
                            ),
                          ),
                          rowWidget(
                            context,
                            'transaction history',
                            IconButton(
                              icon: Icon(Icons.arrow_forward_ios_rounded),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TransactionHistoryScreen()));
                              },
                            ),
                          ),
                          rowWidgetWithNotification(
                            context,
                            'my forum',
                            Stack(
                              alignment: AlignmentDirectional.centerStart,
                              children: [
                                // unread red dot
                                StreamBuilder(
                                    stream: db.collection("myForumPosts").doc(auth.currentUser.uid).snapshots(),
                                    builder: (context, myForumSnapshot) {
                                      if (!myForumSnapshot.hasData) {
                                        return Container(
                                          width: 10,
                                          height: 10,
                                        );
                                      }
                                      var info = myForumSnapshot.data.data();
                                      List<dynamic> unreadList = info["unread"];
                                      if (unreadList == null || unreadList.isEmpty) {
                                        return Container(
                                          width: 10,
                                          height: 10,
                                        );
                                      } else {
                                        return Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                ),
                                // navigate button
                                IconButton(
                                  icon: Icon(Icons.arrow_forward_ios_rounded),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                myForum(context)));
                                  },
                                ),
                              ],
                            )
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              // Navigation bar
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: 4,
                selectedItemColor: Color.fromRGBO(242, 195, 71, 1),
                unselectedItemColor: Colors.grey,
                showUnselectedLabels: true,
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                      icon: Icon(Icons.house), label: "Home"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.art_track), label: "Forum"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.chat_bubble_rounded), label: "Messages"),
                  BottomNavigationBarItem(icon: Icon(Icons.add), label: "Sell"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.person), label: "Profile"),
                ],
                onTap: (index) {
                  if (FirebaseAuth.instance.currentUser == null) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  } else {
                    if (index == 0) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen()));
                    } else if (index == 1) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForumScreen()));
                    } else if (index == 2) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyChatsScreen()));
                    } else if (index == 3) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PostScreen()));
                    }
                  }
                },
              ),
            ),
          );
        });
  }

  // void SelectedItem(BuildContext context, item) {
  //   switch (item) {
  //     case 0:
  //       Navigator.of(context)
  //           .push(MaterialPageRoute(builder: (context) => SettingsScreen()));
  //       break;
  //     case 1:
  //       print("Privacy Clicked");
  //       break;
  //     case 2:
  //       //print("User Logged out");

  //       break;
  //   }
  // }

  _readUserInfo() async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    user = NUSellUser.fromJson(doc.data());
  }

  Future getImage() async {
    await Permission.mediaLibrary.request();
    var tempImage = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 15);
    print('gotten tempImage');
    setState(() {
      newProfilePic = File(tempImage.path);
    });
    print('set newProfilePic');
  }

  uploadImage() async {
    final Reference firestoreStorageRef = FirebaseStorage.instance
        .ref()
        .child('profilepics/${AuthService().getCurrentUID()}');
    print('reference created');
    TaskSnapshot task = await firestoreStorageRef.putFile(newProfilePic);
    print('file uploaded');
    String downloadUrl = await task.ref.getDownloadURL();
    print('downloadUrl got');
    setState(() {
      user.avatarUrl = downloadUrl;
    });
    print('avatarUrl set');
    FirebaseFirestore.instance
        .collection('users')
        .doc(AuthService().getCurrentUID())
        .set({'avatarUrl': user.avatarUrl}, SetOptions(merge: true));
  }
}

Widget myPosts(context) {
  return Scaffold(
    appBar: AppBar(
      title: Text("My posts"),
      leading: BackButton(
        color: Colors.black,
        onPressed: () {
          //Navigator.of(context).pop();
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => ProfileScreen()));
          Navigator.pop(context);
        },
      ),
    ),
    body: AllPostsScreen(
      userId: AuthService().getCurrentUID(),
    ),
  );
}

Widget myReviews(context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Reviews'),
      leading: BackButton(
        color: Colors.black,
        onPressed: () {
          Navigator.pop(context);
          // Navigator.of(context).pushReplacement(
          //     MaterialPageRoute(builder: (context) => ProfileScreen()));
        },
      ),
    ),
    body: ReviewsForUser(
      userId: AuthService().getCurrentUID(),
    ),
  );
}

Widget rowWidget(context, String text, IconButton button) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Text(
                text,
                style: TextStyle(fontSize: 20),
              ),
              height: 32,
            ),
            button
          ],
        ),
      ),
      Container(
          height: 1,
          width: MediaQuery.of(context).size.width,
          color: Colors.grey),
    ],
  );
}

Widget rowWidgetWithNotification(context, String text, Stack button) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              child: Text(
                text,
                style: TextStyle(fontSize: 20),
              ),
              height: 32,
            ),
            button
          ],
        ),
      ),
      Container(
          height: 1,
          width: MediaQuery.of(context).size.width,
          color: Colors.grey),
    ],
  );
}

Widget myForum(context) {
  return Scaffold(
    appBar: AppBar(
      leading: BackButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => ProfileScreen()));
        },
      ),
      title: Text("My Forum"),
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
    body: MyForumScreen(),
  );
}
