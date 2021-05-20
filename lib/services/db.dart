import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orbital2796_nusell/models/user.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Future updateUserData(NUSellUser user) async {
    var options = SetOptions(merge: true);
    print('came in here!');
    return await userCollection.doc(uid).set(user.toMap(), options);
  }

  Future deleteuser() {
    return userCollection.doc(uid).delete();
  }
}
