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
import 'package:orbital2796_nusell/screens/post.dart';
import 'package:orbital2796_nusell/screens/profile/avatar.dart';
import 'package:orbital2796_nusell/services/auth.dart';
import 'package:orbital2796_nusell/services/db.dart';

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

  File newProfilePic;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          _readUserInfo();
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return Scaffold(
            appBar: AppBar(
              title: Text('Your Profile'),
              leading: BackButton(
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HomeScreen()));
                },
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FutureBuilder(
                            future: _readUserInfo(),
                            builder: (context, snapshot) {
                              return Avatar(
                                avatarUrl: user.avatarUrl,
                                onTap: () async {
                                  print('waiting for image');
                                  await getImage()
                                      .whenComplete(() => uploadImage());

                                  print('uploaded image');
                                },
                              );
                            }),
                      ],
                    ),
                  ),
                  FutureBuilder(
                      future: _readUserInfo(),
                      builder: (context, snapshot) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Username: ${user.username}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Email: ${user.email}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                'Your phone number: ${user.phoneNumber}',
                                style: TextStyle(fontSize: 16),
                              ),
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
                              child: Text('Log Out'),
                              onPressed: () {
                                AuthService().signout();
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()));
                              },
                            ),
                            ElevatedButton(
                              child: Text('Delete Account'),
                              onPressed: () {
                                User user = FirebaseAuth.instance.currentUser;
                                user.delete();
                                print('Deleted successfully!');
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()));
                              },
                            ),
                          ],
                        );
                      }),
                ],
              ),
            ),

            //a collection of the three buttons
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FloatingActionButton(
                    heroTag: "home",
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => HomeScreen()));
                    },
                    child: Icon(Icons.house),
                  ),
                  FloatingActionButton(
                    heroTag: "post",
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PostScreen()));
                    },
                    child: Icon(Icons.add),
                  ),
                  FloatingActionButton(
                    heroTag: "profile",
                    onPressed: () {},
                    child: Icon(Icons.person),
                  )
                ],
              ),
            ),
          );
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
    var tempImage = await ImagePicker().getImage(source: ImageSource.gallery);
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
    UserDatabaseService(uid: AuthService().getCurrentUID())
        .updateUserData(user);
  }
}
