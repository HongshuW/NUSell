import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  // a list of user IDs.
  List<String> users;

  Chat(this.users);

  Map<String, int> generateStatusMap() {
    int len = users.length;
    Map<String, int> unread = {};
    for (var i = 0; i < len; i++) {
      unread[this.users[i]] = 0;
    }
    return unread;
  }

  Map<String, dynamic> toMap() {
    return {
      'users': users,
      'history': [],
      'unread': generateStatusMap(),
      'lastMessage': Timestamp.now(),
    };
  }
}