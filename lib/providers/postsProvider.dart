import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class postsProvider with ChangeNotifier {
  // default snapshot of posts (sorted by time posted).

  Stream<QuerySnapshot> _snapshot = FirebaseFirestore.instance
      .collection("posts")
      .orderBy("time", descending: true)
      .snapshots();

  Stream<QuerySnapshot> get snapshot => _snapshot;

  set snapshot(Stream<QuerySnapshot> newSnapshot) {
    _snapshot = newSnapshot;
    notifyListeners();
  }

  // Clear previous state and switch to default snapshot of posts.
  clear() {
    _snapshot = FirebaseFirestore.instance
        .collection("posts")
        .orderBy("time", descending: true)
        .snapshots();
  }
}