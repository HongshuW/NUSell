import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/screens/editProfileForm.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:orbital2796_nusell/services/auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ProfileScreen()));
          },
        ),
      ),
      body: ListView(
        children: ListTile.divideTiles(
            //          <-- ListTile.divideTiles
            context: context,
            tiles: [
              ListTile(
                title: Text('Edit profile'),
                trailing: IconButton(
                  icon: Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => EditProfileScreen()));
                  },
                ),
              ),
              ListTile(
                title: Text('Log out'),
                trailing: IconButton(
                  icon: Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            elevation: 10,
                            backgroundColor: Color.fromRGBO(250, 250, 250, 1),
                            child: Container(
                              margin: EdgeInsets.all(30),
                              height: MediaQuery.of(context).size.height * 0.2,
                              child: Column(
                                children: [
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    child: Text(
                                      "Are you sure you want to log out?",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
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
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.white,
                                          side: BorderSide(
                                              color: Color.fromRGBO(
                                                  100, 170, 255, 1)),
                                        ),
                                        child: Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          AuthService().signout();
                                          Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginScreen()));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary:
                                              Color.fromRGBO(100, 170, 255, 1),
                                        ),
                                        child: Text("Log out",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  },
                ),
              ),
              ListTile(
                title: Text('Delete account'),
                trailing: IconButton(
                  icon: Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            elevation: 10,
                            backgroundColor: Color.fromRGBO(250, 250, 250, 1),
                            child: Container(
                              margin: EdgeInsets.all(30),
                              height: MediaQuery.of(context).size.height * 0.2,
                              child: Column(
                                children: [
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    child: Text(
                                      "Are you sure you want to delete your account?",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: Text("This action is irreversible!"),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.white,
                                          side: BorderSide(
                                              color: Color.fromRGBO(
                                                  100, 170, 255, 1)),
                                        ),
                                        child: Text("Cancel"),
                                      ),
                                      StreamBuilder<DocumentSnapshot>(
                                          stream: db
                                              .collection('myPosts')
                                              .doc(
                                                  AuthService().getCurrentUID())
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            return ElevatedButton(
                                              onPressed: () async {
                                                User user = FirebaseAuth
                                                    .instance.currentUser;
                                                user.delete();
                                                String uid = AuthService()
                                                    .getCurrentUID();
                                                Map<String, dynamic> doc =
                                                    snapshot.data.data();
                                                for (var post
                                                    in doc['myPosts']) {
                                                  db
                                                      .collection('posts')
                                                      .doc(post)
                                                      .delete();
                                                }
                                                db
                                                    .collection('myChat')
                                                    .doc(uid)
                                                    .delete();
                                                db
                                                    .collection('myPosts')
                                                    .doc(uid)
                                                    .delete();
                                                db
                                                    .collection(
                                                        'personalPreference')
                                                    .doc(uid)
                                                    .delete();
                                                db
                                                    .collection('reviews')
                                                    .doc(uid)
                                                    .delete();
                                                db
                                                    .collection('searchHistory')
                                                    .doc(uid)
                                                    .delete();
                                                db
                                                    .collection('shopping cart')
                                                    .doc(uid)
                                                    .delete();
                                                print('Deleted successfully!');
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                LoginScreen()));
                                              },
                                              style: ElevatedButton.styleFrom(
                                                primary: Color.fromRGBO(
                                                    100, 170, 255, 1),
                                              ),
                                              child: Text("Delete",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            );
                                          }),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  },
                ),
              ),
            ]).toList(),
      ),
    );
  }
}
