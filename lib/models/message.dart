import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  bool seller;
  Timestamp time;
  String message;

  Message(this.seller, this.time, this.message);

  Map<String, dynamic> toMap() {
    return {
      'seller': seller,
      'time': time,
      'message': message
    };
  }
}