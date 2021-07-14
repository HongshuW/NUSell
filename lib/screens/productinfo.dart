import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orbital2796_nusell/screens/offersReceived.dart';
import 'package:orbital2796_nusell/subProject/recommendation/backgroundTimer.dart';
import 'package:orbital2796_nusell/models/chat.dart';
import 'package:orbital2796_nusell/models/popUp.dart';
import 'package:orbital2796_nusell/screens/editProductForm.dart';
import 'package:orbital2796_nusell/screens/contactSeller.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:orbital2796_nusell/screens/review.dart';
import 'package:orbital2796_nusell/screens/sellerProfile.dart';
import 'package:orbital2796_nusell/screens/shoppingCart.dart';
import 'package:orbital2796_nusell/services/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductInfoScreen extends StatefulWidget {
  final String product;
  // start the timer as the user enters the product information screen.
  final backgroundTimer timer = new backgroundTimer(DateTime.now());

  ProductInfoScreen({Key key, this.product}) : super(key: key);

  @override
  State<ProductInfoScreen> createState() => _ProductInfoScreenState();
}

class _ProductInfoScreenState extends State<ProductInfoScreen> {
  var userId;
  String sellerName;
  String sellerPhoto;

  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference shoppingCart =
      FirebaseFirestore.instance.collection('shopping cart');

  String status;

  int index = 0;
  var len;
  void previousPage(PointerEvent e) {
    if (index > 0) {
      setState(() {
        this.index--;
      });
    }
  }

  void nextPage(PointerEvent e) {
    if (index < this.len - 1) {
      setState(() {
        this.index++;
      });
    }
  }

  getImage(imgArr, index) {
    if (imgArr.isEmpty) {
      return Column(
        children: [
          Container(
            height: 0.5 * MediaQuery.of(context).size.height,
            child: Image.asset(
              'assets/images/defaultPostImage.png',
              fit: BoxFit.fitWidth,
              width: MediaQuery.of(context).size.width,
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Container(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            height: 0.5 * MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    showDialog(
                        barrierColor: Colors.black,
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            child: Container(
                              color: Colors.black,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
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
                                    imageUrl: imgArr[index],
                                    fadeInDuration: Duration.zero,
                                  ),
                                ],
                              ),
                            ),
                            insetPadding: EdgeInsets.all(0),
                          );
                        });
                  },
                  child: GestureDetector(
                    onHorizontalDragEnd: (DragEndDetails details) {
                      if (details.primaryVelocity > 0) {
                        if (index > 0) {
                          setState(() {
                            this.index--;
                          });
                        }
                      } else if (details.primaryVelocity < 0) {
                        if (index < this.len - 1) {
                          setState(() {
                            this.index++;
                          });
                        }
                      }
                    },
                    child: CachedNetworkImage(
                      imageUrl: imgArr[index],
                      fit: BoxFit.fitHeight,
                      width: MediaQuery.of(context).size.width,
                      fadeInDuration: Duration(milliseconds: 250),
                    ),
                  ),
                ),
                Positioned(
                  top: 0.25 * MediaQuery.of(context).size.height - 15,
                  left: 0,
                  child: Container(
                    color: Colors.white38,
                    padding:
                        EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
                    child: Listener(
                        onPointerUp: previousPage,
                        child: Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.grey)),
                  ),
                ),
                Positioned(
                  top: 0.25 * MediaQuery.of(context).size.height - 15,
                  right: 0,
                  child: Container(
                    color: Colors.white38,
                    padding:
                        EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
                    child: Listener(
                        onPointerUp: nextPage,
                        child: Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.grey)),
                  ),
                ),
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: 10),
              child: Text("${this.index + 1} / ${this.len}")),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    this.userId = auth.currentUser.uid;

    // Returns a set of buttons with different functionalities based on the
    // status of the post.
    interactions(String seller, String user) {
      if (seller == user) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // selling: update; deleted: resume; sold: activate.
            this.status == "Selling"
                ? ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              EditProductScreen(product: widget.product)));
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(100, 170, 255, 1),
                    ),
                    child: Text("Update"))
                : ElevatedButton(
                    onPressed: () {
                      DocumentReference docRef =
                          db.collection("posts").doc(widget.product);
                      docRef.update({
                        "status": "Selling",
                        "time": DateTime.parse(DateTime.now().toString())
                      });
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ProfileScreen()));
                    },
                    child:
                        Text(this.status == "Deleted" ? "Resume" : "Activate")),

            // selling: delete; other status: disabled delete.
            this.status == "Selling"
                ? ElevatedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return popUp(
                              title:
                                  "Are you sure you want to delete this post?",
                              subtitle:
                                  "This post will not be shown to the other users after deletion.",
                              confirmText: "Delete",
                              confirmColor: Colors.red,
                              confirmAction: () async {
                                DocumentReference docRef =
                                    db.collection("posts").doc(widget.product);
                                // var doc = await docRef.get();
                                // List<dynamic> images = doc["images"];
                                // for (var img in images) {
                                //   storage.refFromURL(img).delete();
                                // }
                                // docRef.delete();
                                // db.collection("users").doc(user).update({
                                //   "posts": FieldValue.arrayRemove([widget.product])
                                // });
                                // db.collection("myPosts").doc(user).update({
                                //   "myPosts": FieldValue.arrayRemove([widget.product])
                                // });
                                docRef.update({"status": "Deleted"});
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ProfileScreen()));
                              },
                            );
                          });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                    ),
                    child: Text("Delete"))
                : ElevatedButton(
                    child: Text("Delete"),
                    onPressed: null,
                  ),
          ],
        );
      } else {
        Chat chat = new Chat([seller, user]);
        String docID;
        int numOfLikes;
        return StreamBuilder(
            stream: db.collection("posts").doc(widget.product).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              Map<String, dynamic> post = snapshot.data.data();
              if (post['likes'] == null) {
                print(post['likes']);
                db
                    .collection("posts")
                    .doc(widget.product)
                    .set({'likes': 0}, SetOptions(merge: true));
              }
              //print("it is ${post['likes']}");
              return BottomAppBar(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // IconButton(
                    //     icon: Icon(Icons.shopping_cart),
                    //     onPressed: () {
                    //       Navigator.of(context).push(MaterialPageRoute(
                    //           builder: (context) => MyShoppingCartsScreen(
                    //                 userId: AuthService().getCurrentUID(),
                    //               )));
                    //     }),
                    Container(
                      height: 40,
                      width: 40,
                      child: StreamBuilder(
                          stream: db
                              .collection('shopping cart')
                              .doc(AuthService().getCurrentUID())
                              .snapshots(),
                          builder: (context, snapshot2) {
                            bool liked = false;
                            if (!snapshot2.hasData || snapshot2.data == null)
                              return Center(child: CircularProgressIndicator());
                            Map<String, dynamic> posts = snapshot2.data.data();
                            if (posts != null) {
                              var addresses = posts['shopping cart'];

                              for (var post in addresses) {
                                if (post == widget.product) liked = true;
                              }
                            }

                            return IconButton(
                              onPressed: () {
                                if (liked == false) {
                                  numOfLikes = post['likes'] + 1;
                                  print("+1");
                                  db
                                      .collection("posts")
                                      .doc(widget.product)
                                      .set({'likes': numOfLikes},
                                          SetOptions(merge: true));
                                  widget.timer.updatePreference(
                                      post["category"],
                                      post["location"],
                                      post["user"],
                                      0);
                                  shoppingCart
                                      .doc(AuthService().getCurrentUID())
                                      .set({
                                    'shopping cart':
                                        FieldValue.arrayUnion([widget.product]),
                                  }, SetOptions(merge: true));
                                } else {
                                  numOfLikes = post['likes'] - 1;
                                  db
                                      .collection("posts")
                                      .doc(widget.product)
                                      .set({'likes': numOfLikes},
                                          SetOptions(merge: true));
                                  shoppingCart
                                      .doc(AuthService().getCurrentUID())
                                      .update({
                                    "shopping cart":
                                        FieldValue.arrayRemove([widget.product])
                                  });
                                }
                                print(liked);
                              },
                              icon: liked
                                  ? Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                    )
                                  : Icon(Icons.favorite_outline_rounded),
                            );
                          }),
                    ),
                    Text('${post['likes']}'),
                    SizedBox(
                      width: 20,
                    ),

                    ElevatedButton(
                      onPressed: () {
                        if (seller.compareTo(user) < 0) {
                          docID = seller + "_" + user;
                        } else {
                          docID = user + "_" + seller;
                        }
                        db
                            .collection("chats")
                            .doc(docID)
                            .get()
                            .then((snapshot) => {
                                  if (!snapshot.exists)
                                    {
                                      db
                                          .collection("chats")
                                          .doc(docID)
                                          .set(chat.toMap()),
                                      db
                                          .collection("myChats")
                                          .doc(seller)
                                          .get()
                                          .then((sellerSnapshot) => {
                                                if (!sellerSnapshot.exists)
                                                  {
                                                    db
                                                        .collection("myChats")
                                                        .doc(seller)
                                                        .set({
                                                      "myChats": [docID]
                                                    })
                                                  }
                                                else
                                                  {
                                                    db
                                                        .collection("myChats")
                                                        .doc(seller)
                                                        .update({
                                                      "myChats":
                                                          FieldValue.arrayUnion(
                                                              [docID])
                                                    })
                                                  }
                                              }),
                                      db
                                          .collection("myChats")
                                          .doc(user)
                                          .get()
                                          .then((userSnapshot) => {
                                                if (!userSnapshot.exists)
                                                  {
                                                    db
                                                        .collection("myChats")
                                                        .doc(user)
                                                        .set({
                                                      "myChats": [docID]
                                                    })
                                                  }
                                                else
                                                  {
                                                    db
                                                        .collection("myChats")
                                                        .doc(user)
                                                        .update({
                                                      "myChats":
                                                          FieldValue.arrayUnion(
                                                              [docID])
                                                    })
                                                  }
                                              }),
                                    }
                                });
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ContactSellerScreen(
                                  chatID: docID,
                                  theOtherUserId: seller,
                                  theOtherUserName: sellerName,
                                )));
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(100, 170, 255, 1),
                      ),
                      child: Text("Contact the seller"),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          // Navigator.of(context).push(MaterialPageRoute(
                          //     builder: (context) => ReviewScreen(
                          //           product: widget.product,
                          //           seller: post['user'],
                          //         )));
                          showDialog(
                              context: context,
                              builder: (context) {
                                TextEditingController controller =
                                    TextEditingController();
                                return popUp(
                                  title: "Make an offer for this product",
                                  subtitle: "What is your target price",
                                  confirmText: "Submit",
                                  confirmColor:
                                      Color.fromRGBO(100, 170, 255, 1),
                                  hasTextField: true,
                                  textField: TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        contentPadding: EdgeInsets.all(5),
                                        hintText: "e.g. 7.5",
                                        fillColor:
                                            Color.fromRGBO(255, 255, 255, 0.5),
                                        filled: true,
                                      )),
                                  confirmAction: () {
                                    //AuthService().signout();
                                    users
                                        .doc(seller)
                                        .collection('offersReceived')
                                        .doc(widget.product)
                                        .set({
                                      'offers': FieldValue.arrayUnion([
                                        {
                                          'offerFromUser':
                                              AuthService().getCurrentUID(),
                                          'priceOffered': controller.text,
                                          'status': 'Pending'
                                        }
                                      ]),
                                      'status': 'Pending',
                                      'sellerReceivedPayment': false,
                                    }, SetOptions(merge: true));
                                    users
                                        .doc(AuthService().getCurrentUID())
                                        .collection('offersMade')
                                        .doc(widget.product)
                                        .set({
                                      'price': FieldValue.arrayUnion(
                                          [controller.text]),
                                      'status': 'Pending',
                                      'time': DateTime.now(),
                                      'buyerReceivedProduct': false,
                                      'reviewDone': false
                                    }, SetOptions(merge: true));
                                    Navigator.of(context).pop();
                                    Fluttertoast.showToast(
                                        msg:
                                            'You have successfully made an offer');
                                  },
                                );
                              });
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromRGBO(100, 170, 255, 1),
                        ),
                        child: Text('Make an offer'))
                  ],
                ),
              );
            });
      }
    }

    // TODO: implement build
    return StreamBuilder<DocumentSnapshot>(
      stream: db.collection("posts").doc(widget.product).snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        Map<String, dynamic> post = snapshot.data.data();
        this.status = post["status"];
        len = post['images'].length;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: BackButton(
              color: Colors.black,
              onPressed: () {
                if (post["user"] == this.userId) {
                  // Stop the timer, one's own post -> interest level = 0.1.
                  widget.timer.updatePreference(
                      post["category"], post["location"], null, 0.1);
                } else {
                  // Stop the timer, exit the page -> interest level = 0.2.
                  widget.timer.updatePreference(
                      post["category"], post["location"], post["user"], 0.2);
                }
                // go back to the previous screen
                Navigator.pop(context);
              },
            ),
          ),
          body: ListView(
            children: [
              // Product Images
              getImage(post['images'], index),

              // User
              FutureBuilder<DocumentSnapshot>(
                future: db.collection("users").doc("${post['user']}").get(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  Map<String, dynamic> user = userSnapshot.data.data();
                  sellerName = user["username"];
                  sellerPhoto = user["avatarUrl"];
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
                      padding: EdgeInsets.only(left: 30),
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: CachedNetworkImage(
                                imageUrl: sellerPhoto,
                                height: 60,
                                width: 60,
                                fit: BoxFit.fill,
                                fadeInDuration: Duration.zero,
                              ),
                            ),
                          ),
                          Text(
                            "${user["username"]}",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                letterSpacing: 1),
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
                                          padding: EdgeInsets.only(
                                              left: 5, right: 5),
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
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Color.fromRGBO(
                                                          242, 195, 71, 1)),
                                                )
                                              : Text(
                                                  "following",
                                                  style: TextStyle(
                                                      fontSize: 16,
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

              // Time, Location, Category
              Container(
                padding: EdgeInsets.only(left: 30, right: 30),
                margin: EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    Text(
                      "${DateTime.fromMillisecondsSinceEpoch(post["time"].millisecondsSinceEpoch)}"
                          .substring(0, 10),
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      padding: EdgeInsets.only(left: 5, right: 5),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(10),
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 15,
                          ),
                          Text(
                            "${post['location']}",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      padding: EdgeInsets.only(left: 5, right: 5),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(10),
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.category, size: 15),
                          Text(
                            "${post['category']}",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Product Name
              Container(
                padding: EdgeInsets.only(left: 30, right: 30),
                child: Row(
                  children: [
                    Icon(
                      Icons.article,
                    ),
                    Text(
                      " ${post['productName']}",
                      style: TextStyle(fontSize: 16, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),

              // Price
              Container(
                padding: EdgeInsets.only(left: 30, right: 30),
                child: Row(
                  children: [
                    Icon(Icons.attach_money),
                    Text(
                      " ${post['price']}",
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              // Description
              Container(
                padding: EdgeInsets.only(left: 30, right: 30),
                child: Text(
                  "\nDescription: ",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 30, right: 30),
                margin: EdgeInsets.only(top: 5, bottom: 20),
                child: Text("${post['description']} \n"),
              ),

              // Interactions
              //interactions(post['user'], this.userId),
            ],
          ),
          bottomNavigationBar: interactions(post['user'], this.userId),
        );
      },
    );
  }
}
