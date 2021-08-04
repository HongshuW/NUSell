import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class AppMessage {
  // The index used to get user id in the array `users` of a chat.
  int userIndex;
  Timestamp time;
  var message;

  AppMessage(this.userIndex, this.time, this.message);

  Map<String, dynamic> toMap() {
    return {'user': userIndex, 'time': time, 'message': message};
  }
}

class ImageMessage extends AppMessage {
  ImageMessage(userIndex, time, message) : super(userIndex, time, message);

  @override
  Map<String, dynamic> toMap() {
    return {'user': userIndex, 'time': time, 'imgURL': message};
  }
}

class LinkMessage extends AppMessage {
  LinkMessage(userIndex, time, message) : super(userIndex, time, message);

  @override
  Map<String, dynamic> toMap() {
    return {'user': userIndex, 'time': time, 'productId': message};
  }
}
