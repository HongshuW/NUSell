import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class postsProvider with ChangeNotifier {
  // default snapshot of posts (sorted by time posted).
  Query<Map<String, dynamic>> _snapshot;

  Query<Map<String, dynamic>> get snapshot => _snapshot;

  set snapshot(Query<Map<String, dynamic>> newSnapshot) {
    _snapshot = newSnapshot;
    notifyListeners();
  }
}