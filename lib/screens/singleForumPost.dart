import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/models/comment.dart';
import 'package:orbital2796_nusell/models/loading.dart';
import 'package:orbital2796_nusell/models/popUp.dart';
import 'package:orbital2796_nusell/screens/myForum.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:orbital2796_nusell/screens/sellerProfile.dart';
import 'package:orbital2796_nusell/subProject/recommendation/backgroundTimer.dart';

class SingleForumPost extends StatefulWidget {
  final DocumentSnapshot post;
  final bool commented;
  SingleForumPost({Key key, this.post, this.commented}) : super(key: key);
  @override
  _SingleForumPostState createState() => _SingleForumPostState();
}

class _SingleForumPostState extends State<SingleForumPost> {
  var auth = FirebaseAuth.instance;
  var db = FirebaseFirestore.instance;

  String userId;
  String content = "";
  Comment comment;
  TextEditingController _controller = TextEditingController();

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
                fit: BoxFit.cover,
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
    this.userId = auth.currentUser.uid;
    // set cursor position to be end of the text.
    _controller.text = this.content;
    _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length));

    return Container(
        padding: EdgeInsets.only(top: widget.commented ? 10 : 20,
            bottom: 20, left: 20, right: 20),
        margin: EdgeInsets.only(top: 10, left: 20, right: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.1)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          children: [
            // more actions
            widget.commented
                ? Container(
              height: 20,
              alignment: Alignment.topRight,
              child: IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.topRight,
                splashRadius: 12,
                icon: Icon(Icons.keyboard_arrow_down),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          height: 150,
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return popUp(
                                          title: "Do you want to hide this post?",
                                          subtitle: "This action is irreversible!",
                                          confirmText: "Confirm",
                                          confirmAction: () async {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return loading(
                                                    hasMessage: false,
                                                    message: "Processing...",
                                                  );
                                                });
                                            await db.collection("myForumPosts")
                                                .doc(this.userId).update({
                                              "commented": FieldValue.arrayRemove([widget.post.id])
                                            });
                                            Navigator.of(context).push(
                                                MaterialPageRoute(builder:
                                                    (context) => myForum(context)));
                                          },
                                        );
                                      });
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  padding: EdgeInsets.all(15),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            width: 0.5,
                                          color: Colors.grey
                                        )
                                    ),
                                  ),
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 10),
                                            child: Icon(Icons.clear)
                                        ),
                                        Text(
                                            "Hide",
                                          style: TextStyle(
                                            fontSize: 16
                                          ),
                                        ),
                                      ],
                                    ),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    primary: Color.fromRGBO(0, 0, 0, 0.1),
                                  shadowColor: Colors.transparent,
                                ),
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          ),
                        );
                      }
                  );
                },
              ),
            ) : Container(),

            // User Information
            FutureBuilder<DocumentSnapshot>(
              future: db.collection("users").doc("${widget.post['user']}").get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                if (!userSnapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                Map<String, dynamic> user = userSnapshot.data.data();
                String userName = user["username"] == null
                    ? widget.post["user"] : user["username"];
                String userPhoto = user["avatarUrl"];
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      // profile photo
                      InkWell(
                        onTap: () {
                          if (widget.post['user'] == this.userId) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ProfileScreen()));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => SellerProfileScreen(
                                    sellerId: widget.post['user'])));
                          }
                        },
                        child: Container(
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
                      ),

                      // user name and time
                      InkWell(
                        onTap: () {
                          if (widget.post['user'] == this.userId) {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ProfileScreen()));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => SellerProfileScreen(
                                    sellerId: widget.post['user'])));
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14),
                            ),
                            Text(
                              getTimePosted(widget.post),
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 1),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        width: 20,
                      ),

                      widget.post['user'] != this.userId
                          ? StreamBuilder<DocumentSnapshot>(
                          stream: db
                              .collection('follow')
                              .doc(this.userId)
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
                              if (widget.post['user'] == user)
                                following = true;
                            }

                            return GestureDetector(
                                child: InkWell(
                                  onTap: () {
                                    db
                                        .collection('follow')
                                        .doc(this.userId)
                                        .set({
                                      'following': FieldValue.arrayUnion(
                                          [widget.post['user']])
                                    }, SetOptions(merge: true));
                                    db
                                        .collection('follow')
                                        .doc(widget.post['user'])
                                        .set({
                                      'followers': FieldValue.arrayUnion(
                                          [this.userId])
                                    }, SetOptions(merge: true));
                                    var timer = backgroundTimer(null);
                                    timer.updatePreference(null, null, widget.post['user'], 0);
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
                          : Container(),
                    ],
                  ),
                );
              },
            ),

            // content
            Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(bottom: 10),
                child: Text(widget.post["content"])
            ),

            // images
            displayImages(widget.post),

            // comments
            ExpansionTile(
              trailing: Container(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.message_outlined, size: 18),
                    Text(
                      widget.post["comments"].length.toString(),
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
                    textInputAction: TextInputAction.send,
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
                    controller: _controller,
                    onChanged: (value) {
                      this.content = value;
                    },
                    onSubmitted: (value) async {
                      this.content = value;
                      if (this.content != "") {
                        this.comment = Comment(user: this.userId,
                            content: this.content, mention: "");
                        db.collection("forumPosts").doc(widget.post.id).update({
                          "comments": FieldValue.arrayUnion([this.comment.toMap()]),
                        });
                        if (widget.post['user'] != this.userId) {
                          db.collection("myForumPosts").doc(this.userId).update({
                            "commented": FieldValue.arrayUnion([widget.post.id]),
                          });
                        }
                        _controller.text = "";
                        this.content = "";
                        this.comment = null;
                      }
                    },
                  ),
                ),
              ] + widget.post["comments"].reversed.map<Widget>((comment) {
                return InkWell(
                  onTap: () {
                    showModalBottomSheet(context: context,
                        builder: (context) {
                          return Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                child: TextField(
                                  autofocus: true,
                                  textInputAction: TextInputAction.send,
                                  keyboardType: TextInputType.multiline,
                                  minLines: 1,
                                  maxLines: 1,
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
                                  controller: _controller,
                                  onChanged: (value) {
                                    this.content = value;
                                  },
                                  onSubmitted: (value) async {
                                    this.content = value;
                                    if (this.content != "") {
                                      this.comment = Comment(user: this.userId,
                                          content: this.content, mention: comment["user"]);
                                      db.collection("forumPosts").doc(widget.post.id).update({
                                        "comments": FieldValue.arrayUnion([this.comment.toMap()]),
                                      });
                                      if (widget.post['user'] != this.userId) {
                                        db.collection("myForumPosts").doc(this.userId).update({
                                          "commented": FieldValue.arrayUnion([widget.post.id]),
                                        });
                                      }
                                      _controller.text = "";
                                      this.content = "";
                                      this.comment = null;
                                      Navigator.of(context).pop();
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                        border: Border(
                            top: BorderSide(width: 0.5, color: Color.fromRGBO(242, 195, 71, 1))
                        )
                    ),
                    // single comment
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User
                        FutureBuilder<DocumentSnapshot>(
                          future: db.collection("users").doc(comment['user']).get(),
                          builder: (context, userSnapshot) {
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
                              child: Row(
                                children: [
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      userName,
                                      style: TextStyle(color: Colors.brown),
                                    ),
                                  ),

                                  // get mentioned user
                                  comment["mention"] != ""
                                      ? FutureBuilder<DocumentSnapshot>(
                                      future: db.collection("users").doc(comment['mention']).get(),
                                      builder: (context, mentionSnapshot) {
                                        if (!mentionSnapshot.hasData) {
                                          return Center(child: CircularProgressIndicator());
                                        }
                                        Map<String, dynamic> mention = mentionSnapshot.data.data();
                                        String mentionedUser = mention["username"] == null
                                            ? " @ ${comment['mention']}" : " @ ${mention["username"]}";
                                        return InkWell(
                                          onTap: () {
                                            if (comment['mention'] == this.userId) {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(builder:
                                                      (context) => ProfileScreen()));
                                            } else {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(builder:
                                                      (context) => SellerProfileScreen(
                                                      sellerId: comment['mention'])));
                                            }
                                          },
                                          child: Text(
                                            mentionedUser,
                                            style: TextStyle(color: Colors.brown),
                                          ),
                                        );
                                      }) : Container(),
                                ],
                              ),
                            );
                          },
                        ),

                        Text(comment["message"])
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ));
  }
}