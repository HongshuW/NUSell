import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:orbital2796_nusell/models/user.dart';
import 'package:orbital2796_nusell/services/auth.dart';

class EditProfileImageScreen extends StatefulWidget {
  const EditProfileImageScreen({Key key}) : super(key: key);

  @override
  _EditProfileImageScreenState createState() => _EditProfileImageScreenState();
}

class _EditProfileImageScreenState extends State<EditProfileImageScreen> {
  NUSellUser user = NUSellUser();
  File newProfilePic;
  // String defaultProfileImage;

  // Future getDefaultImage() async {
  //   defaultProfileImage = await FirebaseStorage.instance
  //       .ref()
  //       .child('profilepics/default-user-image.png')
  //       .getDownloadURL();
  // }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('You profile photo'),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ProfileScreen()));
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(AuthService().getCurrentUID())
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting)
              return CircularProgressIndicator();
            Map<String, dynamic> doc = snapshot.data.data();
            return Center(
              child: GestureDetector(
                onTap: () async {
                  print('waiting for image');
                  await getImage().whenComplete(() => uploadImage());

                  print('uploaded image');
                },
                child: Container(
                  child: CachedNetworkImage(
                    imageUrl: doc['avatarUrl'],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
