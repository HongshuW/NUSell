import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class postsProvider with ChangeNotifier {
  // default snapshot of posts (sorted by time posted).
  Query<Map<String, dynamic>> _snapshot = FirebaseFirestore.instance
      .collection("posts")
      .orderBy("time", descending: true);

  Query<Map<String, dynamic>> get snapshot => _snapshot;

  set snapshot(Query<Map<String, dynamic>> newSnapshot) {
    _snapshot = newSnapshot;
    notifyListeners();
  }

  // Clear previous state and switch to default snapshot of posts.
  clear() {
    _snapshot = FirebaseFirestore.instance
        .collection("posts")
        .orderBy("time", descending: true);
  }
}