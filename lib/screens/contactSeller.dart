import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:orbital2796_nusell/models/message.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ContactSellerScreen extends StatefulWidget {
  final String chatID;
  final String theOtherUserName;
  final String theOtherUserPhoto;
  ContactSellerScreen({Key key, this.chatID, this.theOtherUserName, this.theOtherUserPhoto}) : super(key: key);

  @override
  State<ContactSellerScreen> createState() => _ContactSellerScreenState();
}

class _ContactSellerScreenState extends State<ContactSellerScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    ? Color.fromRGBO(242, 195, 71, 0.7)
                    : Colors.white,
                margin: userIndex == message["user"]
                    ? BubbleEdges.only(bottom: 15, left: 70)
                    : BubbleEdges.only(bottom: 15, right: 70),
                child: message["message"] != null 
                    ? Text(
                    message["message"], 
                    style: TextStyle(fontSize: 16))
                    : ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 200,
                          maxWidth: 150,
                        ),
                        child: CachedNetworkImage(
                          imageUrl: message["imgURL"],
                          fadeInDuration: const Duration(milliseconds: 10),),
                      )
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

  // upload image or take a photo from device.
  Future<String> uploadImage(bool gallery) async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;
    if (gallery) {
      pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 30,
      );
    } else {
      pickedFile = await picker.getImage(
        source: ImageSource.camera,
        imageQuality: 30,
      );
    }
    File img = File(pickedFile.path);
    Reference ref = storage.ref().child('chatpics/${basename(img.path)}');
    await ref.putFile(File(img.path));
    String url = await ref.getDownloadURL();
    return url;
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
                      history = List.from(chat["history"].reversed);
                      this.userIndex = getUserIndex(this.userId, chat["users"]);
                    }
                    return Container(
                      margin: EdgeInsets.only(left: 30, right: 30),
                      child: ListView(
                        reverse: true,
                        children: displayMessages(history),
                      ),
                    );
                  },
                ),
              ),

              // Input text, return to send message.
              Container(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                padding: EdgeInsets.only(top: 5, bottom: 20),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 10),
                      width: MediaQuery.of(context).size.width * 0.65,
                      height: 40,
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
                    InkWell(
                      onTap: () async {
                        String url = await uploadImage(true);
                        this.message = ImageMessage(userIndex, Timestamp.now(), url);
                        db.collection("chats").doc(widget.chatID)
                            .update({"history": FieldValue.arrayUnion([this.message.toMap()])});
                        this.message = null;
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.1,
                        height: MediaQuery.of(context).size.width * 0.1,
                        margin: EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.black,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.1),
                        ),
                        child: Icon(Icons.add_photo_alternate, size: 20),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        String url = await uploadImage(false);
                        this.message = ImageMessage(userIndex, Timestamp.now(), url);
                        db.collection("chats").doc(widget.chatID)
                            .update({"history": FieldValue.arrayUnion([this.message.toMap()])});
                        this.message = null;
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.1,
                        height: MediaQuery.of(context).size.width * 0.1,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.1),
                        ),
                        child: Icon(Icons.camera_alt, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}