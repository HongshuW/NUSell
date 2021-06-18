import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orbital2796_nusell/models/message.dart';

class ContactSellerScreen extends StatefulWidget {
  final String chatID;
  final String theOtherUserName;
  ContactSellerScreen({Key key, this.chatID, this.theOtherUserName}) : super(key: key);

  @override
  State<ContactSellerScreen> createState() => _ContactSellerScreenState();
}

class _ContactSellerScreenState extends State<ContactSellerScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  // information of this chat.
  Map<String, dynamic> chat;
  // content of a message.
  String content;
  // the current user's id.
  String userId;
  // the current user's index.
  int userIndex;
  Message message;

  // Display all previous messages as a list of widgets.
  displayMessages(List<dynamic> history) {
    return history.map((message) =>
        Row(
          mainAxisAlignment: userIndex == message["user"]
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Bubble(
                alignment: userIndex == message["user"]
                    ? Alignment.topRight
                    : Alignment.topLeft,
                nip: userIndex == message["user"]
                    ? BubbleNip.rightTop
                    : BubbleNip.leftTop,
                color: userIndex == message["user"]
                    ? Color.fromRGBO(242, 195, 71, 0.5)
                    : Colors.white,
                margin: userIndex == message["user"]
                    ? BubbleEdges.only(bottom: 5, left: 50)
                    : BubbleEdges.only(bottom: 5, right: 50),
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

  // In a chat, return the index of the user,
  // return -1 if the user is not in the chat.
  int getUserIndex(String userID, List<dynamic> users) {
    int len = users.length;
    var i;
    for (i = 0; i < len; i++) {
      if (users[i].toString() == userID) {
        return i;
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    this.userId = auth.currentUser.uid;

    return Scaffold(
      appBar: AppBar(
          leading: BackButton(),
        title: Text(widget.theOtherUserName),
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
                  // get information of the current chat.
                  future: db.collection("chats").doc(widget.chatID).get(),
                  builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    this.chat = snapshot.data.data();
                    // list of previous messages.
                    List<dynamic> history = [];
                    if (chat != null) {
                      history = chat["history"];
                      this.userIndex = getUserIndex(this.userId, chat["users"]);
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

              // Input text, return to send message.
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
                    this.message = Message(this.userIndex, Timestamp.now(), this.content);
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