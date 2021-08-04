import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orbital2796_nusell/models/popUp.dart';
import 'package:orbital2796_nusell/screens/contactSeller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:orbital2796_nusell/screens/forum.dart';
import 'package:orbital2796_nusell/screens/home.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:orbital2796_nusell/screens/post.dart';
import 'package:orbital2796_nusell/screens/profile.dart';

class MyChatsScreen extends StatefulWidget {
  MyChatsScreen({Key key}) : super(key: key);

  @override
  _MyChatsScreenState createState() => _MyChatsScreenState();
}

class _MyChatsScreenState extends State<MyChatsScreen> {
  // database
  final FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  // user id of the current user.
  String user;
  // A list of all of the user's chats.
  List<dynamic> myChats;

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

  // Display the list of chats as widgets, each of which will lead to
  // its corresponding page if tapped.
  displayChats() {
    List<Widget> chats = [];
    int len = myChats.length;
    var i;

    // for each chat, add a corresponding widget to the list `chats`.
    for (i = 0; i < len; i++) {
      String chatID = myChats[i];
      chats.add(StreamBuilder(
          stream: db.collection("chats").doc(chatID).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            Map<String, dynamic> chatInfo = snapshot.data.data();
            // the index of current user
            int userIndex = getUserIndex(this.user, chatInfo["users"]);
            var theOtherUser =
                userIndex == 0 ? chatInfo["users"][1] : chatInfo["users"][0];

            return FutureBuilder(
                // get the information of the other user
                future: db.collection("users").doc(theOtherUser).get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  Map<String, dynamic> userInfo = snapshot.data.data();
                  // if the other user's account has been deleted, provides
                  // delete this chat function
                  if (userInfo == null) {
                    return InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return popUp(
                                title: "This account has been deleted.",
                                confirmText: "Delete this chat",
                                confirmColor: Colors.red,
                                confirmAction: () {
                                  db.collection("myChats").doc(user).update({
                                    "myChats": FieldValue.arrayRemove([chatID]),
                                  });
                                  db.collection("chats").doc(chatID).delete();
                                  Navigator.of(context).pop();
                                },
                              );
                            });
                      },
                      child: Card(
                        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                        color: Colors.grey,
                        child: Row(
                          children: [
                            // profile photo of the other user
                            Container(
                              margin: EdgeInsets.only(left: 5, right: 20),
                              color: Color.fromRGBO(0, 0, 0, 0.1),
                              child: CachedNetworkImage(
                                imageUrl: null,
                                width: 60,
                                height: 60,
                                fit: BoxFit.fill,
                              ),
                            ),

                            // the other user's name and the last message for this chat
                            Flexible(
                              child: Container(
                                height: 60,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "This account has been disabled",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(
                                      chatInfo["history"].isEmpty
                                          ? ""
                                          : chatInfo["history"].last["message"] != null
                                              ? chatInfo["history"].last["message"]
                                              : chatInfo["history"].last["imgURL"] != null
                                                ? "[photo]"
                                                : "[link]",
                                      style: TextStyle(color: Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ContactSellerScreen(
                              chatID: chatID,
                              theOtherUserId: theOtherUser,
                              theOtherUserName: userInfo["username"])));
                    },
                    child: Card(
                      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: Row(
                        children: [
                          // profile photo of the other user
                          Container(
                            margin: EdgeInsets.only(left: 5, right: 20),
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            child: CachedNetworkImage(
                              imageUrl: userInfo["avatarUrl"],
                              width: 60,
                              height: 60,
                              fit: BoxFit.fill,
                            ),
                          ),

                          // the other user's name and the last message for this chat
                          Flexible(
                            child: Container(
                              height: 60,
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    userInfo["username"] == null
                                        ? chatID
                                        : userInfo["username"],
                                    style: TextStyle(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    chatInfo["history"].isEmpty
                                        ? ""
                                        : chatInfo["history"].last["message"] != null
                                          ? chatInfo["history"].last["message"]
                                          : chatInfo["history"].last["imgURL"] != null
                                            ? "[photo]"
                                            : "[link]",
                                    style: TextStyle(color: Colors.grey),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // number of unread messages
                          chatInfo["unread"] == null || chatInfo["unread"][this.user] == 0
                              ? Container()
                              : Container(
                                  height: 15,
                                  width: 15,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.red,
                                  ),
                                  child: Text(
                                    chatInfo["unread"][this.user].toString(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300,
                                        fontSize: 12),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  );
                });
          }));
    }
    return chats;
  }

  BottomNavigationBar getNavigation(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      selectedItemColor: Color.fromRGBO(242, 195, 71, 1),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.house), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.art_track), label: "Forum"),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_rounded), label: "Messages"),
        BottomNavigationBarItem(icon: Icon(Icons.add), label: "Sell"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
      onTap: (index) {
        if (FirebaseAuth.instance.currentUser == null) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false
          );
        } else {
          if (index == 0) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen()),
                    (route) => false
            );
          } else if (index == 1) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => ForumScreen()),
                  (route) => false
            );
          } else if (index == 3) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => PostScreen()),
                    (route) => false
            );
          } else if (index == 4) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
                    (route) => false
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    this.user = auth.currentUser.uid;

    return StreamBuilder<DocumentSnapshot>(
      // get information of all of the user's chats.
      stream: db.collection("myChats").doc(this.user).snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        Map<String, dynamic> chatData = snapshot.data.data();
        if (chatData == null) {
          return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                automaticallyImplyLeading: false,
                title: Text("My Chats"),
              ),
              body: Center(child: Text("You don't have any conversation.")),
              // Navigation bar
              bottomNavigationBar: getNavigation(context),
            ),
          );
        }
        this.myChats = chatData["myChats"];
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              automaticallyImplyLeading: false,
              title: Text("My Chats"),
            ),
            body: Container(
              color: Color.fromRGBO(195, 215, 223, 0.2),
              child: ListView(
                children: displayChats(),
              ),
            ),
            // Navigation bar
            bottomNavigationBar: getNavigation(context),
          ),
        );
      },
    );
  }
}
