import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orbital2796_nusell/models/message.dart';

class ContactSellerScreen extends StatefulWidget {
  final String chatID;
  ContactSellerScreen({Key key, this.chatID}) : super(key: key);

  @override
  State<ContactSellerScreen> createState() => _ContactSellerScreenState();
}

class _ContactSellerScreenState extends State<ContactSellerScreen> {

  final FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  String content;
  bool isSeller;
  String userId;
  Message message;

  displayMessages(List<dynamic> history) {
    return history.map((message) =>
        Row(
          mainAxisAlignment: isSeller == message["seller"]
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Bubble(
                alignment: isSeller == message["seller"]
                    ? Alignment.topRight
                    : Alignment.topLeft,
                nip: isSeller == message["seller"]
                    ? BubbleNip.rightTop
                    : BubbleNip.leftTop,
                color: isSeller == message["seller"]
                    ? Color.fromRGBO(242, 195, 71, 0.5)
                    : Colors.white,
                margin: isSeller == message["seller"]
                    ? BubbleEdges.only(bottom: 5, left: 100)
                    : BubbleEdges.only(bottom: 5, right: 100),
                child: Text(
                    message["message"],
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        )
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    this.userId = auth.currentUser.uid;

    return Scaffold(
      appBar: AppBar(
          leading: BackButton(),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          color: Color.fromRGBO(0, 0, 0, 0.1),
          child: ListView(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.8,
                child: FutureBuilder<DocumentSnapshot>(
                  future: db.collection("chats").doc(widget.chatID).get(),
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    Map<String, dynamic> chat = snapshot.data.data();
                    List<dynamic> history = [];
                    isSeller = false;
                    if (chat != null) {
                      history = chat["history"];
                      isSeller = chat["sellerID"] == this.userId;
                    }
                    return Container(
                      margin: EdgeInsets.all(30),
                      child: ListView(
                        children: displayMessages(history),
                      ),
                    );
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: TextField(
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black45),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                  ),
                  controller: TextEditingController(text: this.content),
                  onChanged: (value) {
                    this.content = value;
                  },
                  onSubmitted: (value) {
                    this.content = value;
                    this.message = Message(isSeller, Timestamp.now(), this.content);
                    db.collection("chats").doc(widget.chatID)
                        .update({"history": FieldValue.arrayUnion([this.message.toMap()])});
                    this.content = "";
                    this.message = null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}