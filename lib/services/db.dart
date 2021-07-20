import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orbital2796_nusell/models/user.dart';

class UserDatabaseService {
  final String uid;
  UserDatabaseService({this.uid});

  // final CollectionReference userCollection =
  //     FirebaseFirestore.instance.collection('users');
  FirebaseFirestore db = FirebaseFirestore.instance;

  //create + update
  Future updateUserData(NUSellUser user) async {
    var options = SetOptions(merge: true);
    print('came in here!');
    return await db.collection('users').doc(uid).set(user.toMap(), options);
  }

  Future setUpFollow(NUSellUser user) async {
    var options = SetOptions(merge: true);
    return await db.collection('follow').doc(uid).set({
      'following': FieldValue.arrayUnion([]),
      'followers': FieldValue.arrayUnion([])
    });
  }

  Future setUpSearch(NUSellUser user) async {
    var options = SetOptions(merge: true);
    return await db.collection('searchHistory').doc(uid).set({
      'searchHistory': FieldValue.arrayUnion([]),
    });
  }

  Future updateProfilePic(picUrl) async {
    print('came in to update url');
    await FirebaseAuth.instance.currentUser
        .updateProfile(photoURL: picUrl)
        .then((value) {
      FirebaseFirestore.instance
          .collection('/users')
          .doc(uid)
          .update({'avartarUrl': picUrl}).then((value) {
        print('Updated');
      }).catchError((e) {
        print(e);
      });
    }).catchError((e) {
      print(e);
    });
  }

  //delete
  Future deleteUser() {
    return db.collection('users').doc(uid).delete();
  }

  //get uer data
  // Stream<List<NUSellUser>> getUserData(NUSellUser user) {
  //   return db
  //       .collection('users')
  //       .where('uid', isEqualTo: user.uid)
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs
  //           .map((doc) => NUSellUser.fromJson(doc.data()))
  //           .toList());
  // }
  Future getUser() async {
    var userData = await db.collection('users').doc(this.uid).get();
    return NUSellUser.fromJson(userData.data());
  }
}
