import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orbital2796_nusell/screens/contactSeller.dart';

class MyChatsScreen extends StatefulWidget{
  MyChatsScreen({Key key}) : super(key: key);

  @override
  _MyChatsScreenState createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  String user;
  List<dynamic> myChats;

  displayChats() {
    List<Widget> chats = [];
    int len = myChats.length;
    var i;
    for (i = 0; i < len; i++) {
      String chatID = myChats[i];
      chats.add(
        FutureBuilder(
          future: db.collection("chats").doc(chatID).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              Map<String, dynamic> chatInfo = snapshot.data.data();
              String seller = chatInfo["sellerID"];
              String customer = chatInfo["customerID"];
              bool isSeller = seller == this.user;
              return Container(
                margin: EdgeInsets.all(20),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder:
                              (context) => ContactSellerScreen(chatID: chatID)
                      )
                    );
                  },
                  child: isSeller ? Text(customer) : Text(seller),
                ),
              );
            })
      );
    }
    return chats;
  }

  @override
  Widget build(BuildContext context) {
    this.user = auth.currentUser.uid;
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: FutureBuilder<DocumentSnapshot>(
          future: db.collection("users").doc(this.user).get(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            Map<String, dynamic> userData = snapshot.data.data();
            myChats = userData["chats"];
            return ListView(
              children: displayChats(),
            );
          },
        ),
      ),
    );
  }
}