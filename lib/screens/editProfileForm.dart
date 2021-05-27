import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/models/user.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:orbital2796_nusell/services/auth.dart';
import 'package:orbital2796_nusell/services/db.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String _username, _phoneNumber, _password, _gender;
  TextEditingController password = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  final Stream<DocumentSnapshot> _userStream = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser.uid)
      .snapshots();
  NUSellUser user;

  _setUser() async {
    user =
        await UserDatabaseService(uid: AuthService().getCurrentUID()).getUser();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _userStream,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          _setUser();
          return Scaffold(
              backgroundColor: Color.fromRGBO(255, 255, 255, 1.0),
              appBar: AppBar(
                backgroundColor: Color.fromRGBO(252, 228, 70, 1),
                title: Text(
                  'Edit your profile',
                  style: TextStyle(color: Colors.black),
                ),
                leading: BackButton(
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProfileScreen()));
                  },
                ),
              ),
              body: Center(
                child: Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Please choose your gender',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            DropdownButtonFormField(
                              value: _gender,
                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(25.0),
                                borderSide: new BorderSide(),
                              )),
                              onSaved: (value) {
                                setState(() {
                                  _gender = value;
                                });
                              },
                              onChanged: (value) {
                                setState(() {
                                  _gender = value;
                                });
                              },
                              items: ['Female', 'Male']
                                  .map((label) => DropdownMenuItem(
                                        child: Text(label.toString()),
                                        value: label,
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      // inputFormField(
                      //     'Username',
                      //     _username,
                      //     'Please enter your username',
                      //     TextInputType.name,
                      //     false),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Username',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            TextFormField(
                              //controller: controller,

                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(25.0),
                                borderSide: new BorderSide(),
                              )),
                              onChanged: (value) {
                                setState(() {
                                  _username = value.trim();
                                });
                              },
                              onSaved: (value) {
                                setState(() {
                                  _username = value.trim();
                                });
                              },
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Please enter your username';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      // inputFormField(
                      //   'Phone number',
                      //   _phoneNumber,
                      //   'Please enter your phone number',
                      //   TextInputType.phone,
                      //   false,
                      // ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Phone number',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            TextFormField(
                              //controller: controller,

                              keyboardType: TextInputType.visiblePassword,
                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(25.0),
                                borderSide: new BorderSide(),
                              )),
                              onChanged: (value) {
                                setState(() {
                                  _phoneNumber = value.trim();
                                });
                              },
                              onSaved: (value) {
                                setState(() {
                                  _phoneNumber = value.trim();
                                });
                              },
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Password',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            TextFormField(
                              //controller: controller,
                              obscureText: true,
                              keyboardType: TextInputType.visiblePassword,
                              controller: password,
                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(25.0),
                                borderSide: new BorderSide(),
                              )),
                              onChanged: (value) {
                                setState(() {
                                  _password = value.trim();
                                });
                              },
                              onSaved: (value) {
                                setState(() {
                                  _password = value.trim();
                                });
                              },
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (_formkey.currentState.validate()) {
                                    _formkey.currentState.save();

                                    //TODO
                                    user.username = _username;
                                    user.phoneNumber = _phoneNumber;
                                    user.gender = _gender;
                                    user.password = _password;
                                    print(user.username);
                                    UserDatabaseService(
                                            uid: FirebaseAuth
                                                .instance.currentUser.uid)
                                        .updateUserData(user);
                                    print('saved');
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProfileScreen()));
                                  } else {
                                    print('unsuccessful!');
                                  }
                                },
                                child: Text(
                                  'Save your profile',
                                  //style: TextStyle(fontSize: 18),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Color.fromRGBO(
                                      242, 195, 71, 1), // background
                                  onPrimary: Colors.black, // foreground
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Positioned(
                              child:
                                  Image.asset('assets/images/wavingLion.png'))
                        ],
                      ),
                    ],
                  ),
                ),
              ));
        });
  }

  // Widget inputFormField(String label, String inputValue, String onErrorHintText,
  //     TextInputType type, bool boolean) {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Column(
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             Text(
  //               label,
  //               style: TextStyle(fontSize: 20),
  //             ),
  //           ],
  //         ),
  //         TextFormField(
  //           //controller: controller,
  //           obscureText: boolean,
  //           keyboardType: type,
  //           decoration: InputDecoration(
  //               border: new OutlineInputBorder(
  //             borderRadius: new BorderRadius.circular(25.0),
  //             borderSide: new BorderSide(),
  //           )),
  //           onChanged: (value) {
  //             setState(() {
  //               inputValue = value.trim();
  //             });
  //           },
  //           onSaved: (value) {
  //             setState(() {
  //               inputValue = value.trim();
  //             });
  //           },
  //           validator: (String value) {
  //             if (value.isEmpty) {
  //               return onErrorHintText;
  //             }
  //             return null;
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
