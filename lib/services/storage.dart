import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:orbital2796_nusell/services/auth.dart';

class StorageService {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instanceFor(
          bucket: "gs://orbital-test-4e374.appspot.com");

  Future<String> uploadFile(File file) async {
    var user = FirebaseAuth.instance.currentUser;
    print(user.uid);
    var storageRef = storage.ref().child("profilepics/${user.uid}");
    var uploadFile = await storageRef.putFile(file);
    String downloadUrl = await uploadFile.ref.getDownloadURL();
    return downloadUrl;
  }
}
