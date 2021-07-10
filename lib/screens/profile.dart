import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orbital2796_nusell/screens/settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:orbital2796_nusell/models/user.dart';
import 'package:orbital2796_nusell/screens/editProfileForm.dart';
import 'package:orbital2796_nusell/screens/home.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:orbital2796_nusell/screens/posts.dart';
import 'package:orbital2796_nusell/screens/myChats.dart';
import 'package:orbital2796_nusell/screens/profile/avatar.dart';
import 'package:orbital2796_nusell/screens/resetPassword.dart';
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
  final FirebaseStorage storage = FirebaseStorage.instance;

  File newProfilePic;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser.uid)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                Map<String, dynamic> doc = snapshot.data.data();
                return Scaffold(
                  appBar: AppBar(
                    title: Text('Your Profile'),
                    leading: BackButton(
                      color: Colors.white,
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => HomeScreen()));
                      },
                    ),
                    actions: [
                      Theme(
                          data: Theme.of(context).copyWith(
                              textTheme:
                                  TextTheme().apply(bodyColor: Colors.black),
                              dividerColor: Colors.white,
                              iconTheme: IconThemeData(color: Colors.white)),
                          child: IconButton(
                            icon: Icon(Icons.settings),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
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
                          height: 240,
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
                                      onTap: () async {
                                        print('waiting for image');
                                        await getImage()
                                            .whenComplete(() => uploadImage());

                                        print('uploaded image');
                                      },
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
                                        'Email: ${doc['email']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Phone number: ${doc['phoneNumber']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ),
                        Row(
                          //scrollDirection: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              child: Text('posts'),
                            ),
                            InkWell(
                              child: Text('reviews'),
                            )
                          ],
                        )
                        // Column(
                        //   children: [
                        // ElevatedButton(
                        //   child: Text('My posts'),
                        //   onPressed: () {
                        //     Navigator.of(context).pushReplacement(
                        //         MaterialPageRoute(
                        //             builder: (context) =>
                        //                 myPosts(context)));
                        //   },
                        // ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                );
              });
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
        color: Colors.white,
        onPressed: () {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => ProfileScreen()));
        },
      ),
    ),
    body: AllPostsScreen(
      userId: AuthService().getCurrentUID(),
    ),
  );
}
