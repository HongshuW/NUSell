import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  // The index used to get user id in the array `users` of a chat.
  int userIndex;
  Timestamp time;
  var message;

  Message(this.userIndex, this.time, this.message);

  Map<String, dynamic> toMap() {
    return {
      'user': userIndex,
      'time': time,
      'message': message
    };
  }
}

class ImageMessage extends Message {
  ImageMessage(userIndex, time, message) : super(userIndex, time, message);

  @override
  Map<String, dynamic> toMap() {
    return {
      'user': userIndex,
      'time': time,
      'imgURL': message
    };
  }
}