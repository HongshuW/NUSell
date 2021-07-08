import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
                        Column(
                          children: [
                            ElevatedButton(
                              child: Text('My posts'),
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            myPosts(context)));
                              },
                            ),
                            ElevatedButton(
                              child: Text('My Chats'),
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => MyChatsScreen()));
                              },
                            ),
                            ElevatedButton(
                              child: Text('Edit your profile'),
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            EditProfileScreen()));
                              },
                            ),
                            ElevatedButton(
                              child: Text('Reset your password'),
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ResetPasswordScreen()));
                              },
                            ),
                            // ElevatedButton(
                            //   child: Text('Log Out'),
                            //   onPressed: () {
                            //     AuthService().signout();
                            //     Navigator.of(context).pushReplacement(
                            //         MaterialPageRoute(
                            //             builder: (context) => LoginScreen()));
                            //   },
                            // ),
                            ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          elevation: 10,
                                          backgroundColor:
                                              Color.fromRGBO(250, 250, 250, 1),
                                          child: Container(
                                            margin: EdgeInsets.all(30),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.2,
                                            child: Column(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      top: 10, bottom: 10),
                                                  child: Text(
                                                    "Are you sure you want to log out?",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                // Container(
                                                //   margin: EdgeInsets.only(
                                                //       bottom: 10),
                                                //   child: Text(
                                                //       "You will need to sign in again to view your account!"),
                                                // ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary: Colors.white,
                                                        side: BorderSide(
                                                            color:
                                                                Color.fromRGBO(
                                                                    100,
                                                                    170,
                                                                    255,
                                                                    1)),
                                                      ),
                                                      child: Text("Cancel"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        AuthService().signout();
                                                        Navigator.of(context)
                                                            .pushReplacement(
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            LoginScreen()));
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary: Color.fromRGBO(
                                                            100, 170, 255, 1),
                                                      ),
                                                      child: Text("Log out",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Color.fromRGBO(255, 88, 68, 1),
                                ),
                                child: Text("Log out")),
                            ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          elevation: 10,
                                          backgroundColor:
                                              Color.fromRGBO(250, 250, 250, 1),
                                          child: Container(
                                            margin: EdgeInsets.all(30),
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.2,
                                            child: Column(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      top: 10, bottom: 10),
                                                  child: Text(
                                                    "Are you sure you want to delete your account?",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: 10),
                                                  child: Text(
                                                      "This action is irreversible!"),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary: Colors.white,
                                                        side: BorderSide(
                                                            color:
                                                                Color.fromRGBO(
                                                                    100,
                                                                    170,
                                                                    255,
                                                                    1)),
                                                      ),
                                                      child: Text("Cancel"),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        User user = FirebaseAuth
                                                            .instance
                                                            .currentUser;
                                                        user.delete();
                                                        print(
                                                            'Deleted successfully!');
                                                        Navigator.of(context)
                                                            .pushReplacement(
                                                                MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            LoginScreen()));
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary: Color.fromRGBO(
                                                            100, 170, 255, 1),
                                                      ),
                                                      child: Text("Delete",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white)),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: Color.fromRGBO(255, 88, 68, 1),
                                ),
                                child: Text("Delete")),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              });
        });
  }

  _readUserInfo() async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get();
    user = NUSellUser.fromJson(doc.data());
  }

  Future getImage() async {
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
