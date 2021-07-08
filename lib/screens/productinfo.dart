import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orbital2796_nusell/models/chat.dart';
import 'package:orbital2796_nusell/screens/home.dart';
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
            height: 300,
            child: Image.asset(
              'assets/images/defaultPostImage.png',
              fit: BoxFit.fitWidth,
              width: 0.7 * MediaQuery.of(context).size.width,
            ),
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Container(
            height: 300,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Listener(
                    onPointerUp: previousPage,
                    child: Icon(Icons.arrow_back_ios)),
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
                  child: Listener(
                    onPointerMove: (PointerMoveEvent event) {
                      int sensitivity = 8;
                      if (event.delta.dx > sensitivity) {
                        // previous image
                        previousPage(event);
                      } else if (event.delta.dx < -sensitivity) {
                        // next image
                        nextPage(event);
                      }
                    },
                    child: CachedNetworkImage(
                      imageUrl: imgArr[index],
                      fit: BoxFit.fitWidth,
                      width: 0.7 * MediaQuery.of(context).size.width,
                      fadeInDuration: Duration(milliseconds: 250),
                    ),
                  ),
                ),
                Listener(
                    onPointerUp: nextPage,
                    child: Icon(Icons.arrow_forward_ios)),
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

    interactions(String seller, String user) {
      if (seller == user) {
        return BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            EditProductScreen(product: widget.product)));
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromRGBO(100, 170, 255, 1),
                  ),
                  child: Text("Update")),
              ElevatedButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            elevation: 10,
                            backgroundColor: Color.fromRGBO(250, 250, 250, 1),
                            child: Container(
                              margin: EdgeInsets.all(30),
                              height: MediaQuery.of(context).size.height * 0.2,
                              child: Column(
                                children: [
                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 10, bottom: 10),
                                    child: Text(
                                      "Are you sure you want to delete this post?",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: Text("This action is irreversible!"),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.white,
                                          side: BorderSide(
                                              color: Color.fromRGBO(
                                                  100, 170, 255, 1)),
                                        ),
                                        child: Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          DocumentReference docRef = db
                                              .collection("posts")
                                              .doc(widget.product);
                                          var doc = await docRef.get();
                                          List<dynamic> images = doc["images"];
                                          for (var img in images) {
                                            storage.refFromURL(img).delete();
                                          }
                                          docRef.delete();
                                          db
                                              .collection("users")
                                              .doc(user)
                                              .update({
                                            "posts": FieldValue.arrayRemove(
                                                [widget.product])
                                          });
                                          db
                                              .collection("myPosts")
                                              .doc(user)
                                              .update({
                                            "myPosts": FieldValue.arrayRemove(
                                                [widget.product])
                                          });
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfileScreen()));
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary:
                                              Color.fromRGBO(100, 170, 255, 1),
                                        ),
                                        child: Text("Delete",
                                            style:
                                                TextStyle(color: Colors.white)),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromRGBO(255, 88, 68, 1),
                  ),
                  child: Text("Delete")),
            ],
          ),
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
                post['likes'] = 0;
              }
              //print("it is ${post['likes']}");
              return BottomAppBar(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // IconButton(
                    //     icon: Icon(Icons.shopping_cart),
                    //     onPressed: () {
                    //       Navigator.of(context).push(MaterialPageRoute(
                    //           builder: (context) => MyShoppingCartsScreen(
                    //                 userId: AuthService().getCurrentUID(),
                    //               )));
                    //     }),
                    IconButton(
                      onPressed: () {
                        bool liked = post['liked'];
                        if (liked == null) {
                          db
                              .collection("posts")
                              .doc(widget.product)
                              .set({'liked': false}, SetOptions(merge: true));
                        }
                        print("liked is ${post['liked']}");
                        if (post['liked'] == false) {
                          numOfLikes = post['likes'] + 1;
                          print("+1");
                          db.collection("posts").doc(widget.product).set(
                              {'likes': numOfLikes, 'liked': true},
                              SetOptions(merge: true));
                          shoppingCart.doc(AuthService().getCurrentUID()).set({
                            'shopping cart':
                                FieldValue.arrayUnion([widget.product]),
                          }, SetOptions(merge: true));
                        } else {
                          numOfLikes = post['likes'] - 1;
                          db.collection("posts").doc(widget.product).set(
                              {'likes': numOfLikes, 'liked': false},
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
                      icon: post['liked']
                          ? Icon(
                              Icons.favorite,
                              color: Colors.red,
                            )
                          : Icon(Icons.favorite_outline_rounded),
                    ),
                    Text("${post['likes']}"),
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
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ReviewScreen(
                                    product: widget.product,
                                    seller: post['user'],
                                  )));
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
        len = post['images'].length;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: BackButton(
              color: Colors.black,
            ),
          ),
          body: Container(
            padding: EdgeInsets.only(left: 30, right: 30),
            child: ListView(
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
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Time, Location, Category
                Container(
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
                Row(
                  children: [
                    Icon(
                      Icons.article,
                    ),
                    Text(
                      " ${post['productName']}",
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),

                // Price
                Row(
                  children: [
                    Icon(Icons.attach_money),
                    Text(
                      " ${post['price']}",
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),

                // Description
                Text(
                  "\nDescription: ",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5, bottom: 20),
                  child: Text("${post['description']} \n"),
                ),

                // Interactions
                //interactions(post['user'], this.userId),
              ],
            ),
          ),
          bottomNavigationBar: interactions(post['user'], this.userId),
        );
      },
    );
  }
}
