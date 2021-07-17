import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/screens/addAForumPost.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:orbital2796_nusell/screens/home.dart';
import 'package:orbital2796_nusell/screens/myChats.dart';
import 'package:orbital2796_nusell/screens/post.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:orbital2796_nusell/screens/sellerProfile.dart';
import 'package:orbital2796_nusell/services/auth.dart';

class ForumScreen extends StatefulWidget {
  ForumScreen({Key key}) : super(key: key);

  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  String userId;

  // a list of document snapshots, each represents a post.
  List<DocumentSnapshot> forumPosts = [];
  // whether the page is loading.
  bool isLoading = false;
  // whether there are more posts in the database.
  bool hasMore = true;
  // number of posts on each load.
  int numPerPage = 10;
  DocumentSnapshot lastDoc;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getPosts();
    // load more when the end of the screen is reached.
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double criteria = 2;
      if (maxScroll - currentScroll < criteria) {
        getPosts();
      }
    });
  }

  // Load posts (depend on the current state) from database.
  getPosts() async {
    if (!hasMore || isLoading) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    QuerySnapshot querySnapshot;
    if (lastDoc == null) {
      querySnapshot = await FirebaseFirestore.instance
          .collection("forumPosts")
          .orderBy("time", descending: true)
          .limit(numPerPage)
          .get();
    } else {
      querySnapshot = await FirebaseFirestore.instance
          .collection("posts")
          .orderBy("time", descending: true)
          .startAfterDocument(lastDoc)
          .limit(numPerPage)
          .get();
    }
    int len = querySnapshot.docs.length;
    if (len < numPerPage) {
      hasMore = false;
    }
    lastDoc = querySnapshot.docs[len - 1];
    forumPosts.addAll(querySnapshot.docs);
    setState(() {
      isLoading = false;
    });
  }
  
  displayImages(DocumentSnapshot post) {
    if (!post['images'].isEmpty) {
      return GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        shrinkWrap: true,
        children: post['images'].map<Widget>((img) {
          return InkWell(
            onTap: () {
              showDialog(
                  barrierColor: Colors.black,
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: Container(
                        color: Colors.black,
                        child: ListView(
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(bottom: 50),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.transparent,
                                ),
                              ),
                            ),
                            CachedNetworkImage(
                              imageUrl: img,
                              fadeInDuration: Duration.zero,
                            ),
                          ],
                        ),
                      ),
                      insetPadding: EdgeInsets.all(0),
                    );});
                  },
                  child: Container(
                    color: Color.fromRGBO(195, 215, 223, 0.2),
                    child: CachedNetworkImage(
                      imageUrl: img,
                      fadeInDuration: Duration.zero,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  );
          }).toList(),
        );
    } else {
      return Container();
    }
  }

  String getTimePosted(DocumentSnapshot post) {
    DateTime currentTime = DateTime.now();
    DateTime timePosted = DateTime
        .fromMillisecondsSinceEpoch(post["time"].millisecondsSinceEpoch);
    Duration difference = currentTime.difference(timePosted);
    int days = difference.inDays;
    if (days == 0) {
      return "Today";
    } else  if (days == 1) {
      return "Yesterday";
    } else if (days <= 7) {
      return "${difference.inDays} days ago";
    } else {
      return "${timePosted}".substring(0, 10);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    userId = auth.currentUser.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text("Forum"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          // publish a forum post.
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddAForumPostScreen()));
              },
              icon: Icon(Icons.camera_alt))
        ],
      ),

      body: Container(
        color: Color.fromRGBO(195, 215, 223, 0.2),
        child: Column(
          children: [
            Expanded(
              child: forumPosts.length == 0
                  ? Center(child: CircularProgressIndicator())
                  : ListView(
                children: forumPosts.map<Widget>((post) {
                  return Container(
                    padding: EdgeInsets.all(20),
                      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.1)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Column(
                        children: [
                          // User
                          FutureBuilder<DocumentSnapshot>(
                            future: db.collection("users").doc("${post['user']}").get(),
                            builder: (BuildContext context,
                                AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                              if (!userSnapshot.hasData) {
                                return Center(child: CircularProgressIndicator());
                              }
                              Map<String, dynamic> user = userSnapshot.data.data();
                              String userName = user["username"] == null
                                  ? post["user"] : user["username"];
                              String userPhoto = user["avatarUrl"];
                              return InkWell(
                                onTap: () {
                                  if (post['user'] == this.userId) {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => ProfileScreen()));
                                  } else {
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) =>
                                            SellerProfileScreen(sellerId: post['user'])));
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    children: [
                                      // profile photo
                                      Container(
                                        margin: EdgeInsets.only(right: 10),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(45),
                                          child: CachedNetworkImage(
                                            imageUrl: userPhoto,
                                            height: 45,
                                            width: 45,
                                            fit: BoxFit.fill,
                                            fadeInDuration: Duration.zero,
                                          ),
                                        ),
                                      ),

                                      // user name and time
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userName,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14),
                                          ),
                                          Text(
                                            getTimePosted(post),
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w300,
                                                letterSpacing: 1),
                                          ),
                                        ],
                                      ),

                                      SizedBox(
                                        width: 20,
                                      ),

                                      post['user'] != AuthService().getCurrentUID()
                                          ? StreamBuilder<DocumentSnapshot>(
                                          stream: db
                                              .collection('follow')
                                              .doc(AuthService().getCurrentUID())
                                              .snapshots(),
                                          builder: (context, snapshotForFollow) {
                                            if (!snapshotForFollow.hasData) {
                                              return CircularProgressIndicator();
                                            }
                                            Map<String, dynamic> mydoc =
                                            snapshotForFollow.data.data();

                                            List usersFollowing = mydoc['following'];
                                            bool following = false;
                                            for (var user in usersFollowing) {
                                              if (post['user'] == user)
                                                following = true;
                                            }

                                            return GestureDetector(
                                                child: InkWell(
                                                  onTap: () {
                                                    db
                                                        .collection('follow')
                                                        .doc(AuthService().getCurrentUID())
                                                        .set({
                                                      'following': FieldValue.arrayUnion(
                                                          [post['user']])
                                                    }, SetOptions(merge: true));
                                                    db
                                                        .collection('follow')
                                                        .doc(post['user'])
                                                        .set({
                                                      'followers': FieldValue.arrayUnion(
                                                          [AuthService().getCurrentUID()])
                                                    }, SetOptions(merge: true));
                                                  },
                                                  child: Container(
                                                      margin: EdgeInsets.only(left: 5),
                                                      padding: EdgeInsets.symmetric(horizontal: 5),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: Color.fromRGBO(
                                                                  242, 195, 71, 1)),
                                                          borderRadius:
                                                          BorderRadius.circular(10),
                                                          color: Colors.transparent),
                                                      child: !following
                                                          ? Text(
                                                        "follow",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                            FontWeight.w300,
                                                            color: Color.fromRGBO(
                                                                242, 195, 71, 1)),
                                                      )
                                                          : Text(
                                                        "following",
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                            FontWeight.w300,
                                                            color: Color.fromRGBO(
                                                                242, 195, 71, 1)),
                                                      )),
                                                ));
                                          })
                                          : Container()
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // content
                          Container(
                            alignment: Alignment.topLeft,
                              margin: EdgeInsets.only(bottom: 10),
                              child: Text(post["content"])
                          ),

                          // images
                          displayImages(post),

                          // comments
                          ExpansionTile(
                              trailing: Container(
                                width: 100,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.message_outlined, size: 18),
                                    Text(
                                      post["commentNum"].toString(),
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w300,
                                          letterSpacing: 3),
                                    ),
                                  ],
                                ),
                              ),
                            children: <Widget>[
                              // write a comment
                              Container(
                                child: TextField(
                                  keyboardType: TextInputType.multiline,
                                  minLines: 1,
                                  maxLines: 3,
                                  maxLength: 100,
                                  decoration: InputDecoration(
                                    hintText: "Write a comment",
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(10),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color.fromRGBO(242, 195, 71, 1)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.black45),
                                    ),
                                  ),
                                  style: TextStyle(fontSize: 14, height: 1),
                                  // controller: TextEditingController(text: this.description),
                                  // onChanged: (value) {
                                  //   this.description = value;
                                  // },
                                ),
                              ),
                            ] + post["comments"].reversed.map<Widget>((comment) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // User
                                  FutureBuilder<DocumentSnapshot>(
                                    future: db.collection("users").doc("${comment['user']}").get(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                                      if (!userSnapshot.hasData) {
                                        return Center(child: CircularProgressIndicator());
                                      }
                                      Map<String, dynamic> user = userSnapshot.data.data();
                                      String userName = user["username"] == null
                                          ? comment['user'] : user["username"];
                                      return InkWell(
                                        onTap: () {
                                          if (comment['user'] == this.userId) {
                                            Navigator.of(context).push(MaterialPageRoute(
                                                builder: (context) => ProfileScreen()));
                                          } else {
                                            Navigator.of(context).push(MaterialPageRoute(
                                                builder: (context) =>
                                                    SellerProfileScreen(sellerId: comment['user'])));
                                          }
                                        },
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          margin: EdgeInsets.only(top: 5),
                                          child: Text(
                                            userName,
                                            style: TextStyle(color: Colors.brown),
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  Text(comment["message"])
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ));
                }).toList(),
              )
            )
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Color.fromRGBO(242, 195, 71, 1),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.house),
              label: "Home"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.art_track),
              label: "Forum"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              label: "Messages"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: "Sell"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile"
          ),
        ],
        onTap: (index) {
          if (auth.currentUser == null) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => LoginScreen()));
          } else {
            if (index == 0) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => HomeScreen()));
            } else if (index == 2) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => MyChatsScreen()));
            } else if (index == 3) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => PostScreen()));
            } else if (index == 4) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => ProfileScreen()));
            }
          }
        },
      ),
    );
  }
}