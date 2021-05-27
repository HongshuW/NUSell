import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

//unused; for testing before only
class AllUserInformation extends StatefulWidget {
  //final NUSellUser user;
  // final String uid;
  // const ProfileScreen({this.uid});
  @override
  _AllUserInformationState createState() => _AllUserInformationState();
}

class _AllUserInformationState extends State<AllUserInformation> {
  final auth = FirebaseAuth.instance;
  final Stream<QuerySnapshot> _userInfo =
      FirebaseFirestore.instance.collection('users').snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _userInfo,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Loading');
          }

          return new ListView(
            children: snapshot.data.docs.map((DocumentSnapshot document) {
              return new ListTile(
                title: new Text(document.get('username')),
                subtitle: new Text(document.get('email')),
              );
            }).toList(),
          );
        });
  }
}
