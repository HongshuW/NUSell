import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/models/user.dart';
import 'package:orbital2796_nusell/models/popUp.dart';
import 'package:orbital2796_nusell/screens/contactSeller.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:orbital2796_nusell/screens/productinfo.dart';

class MyShoppingCartsScreen extends StatefulWidget {
  final String userId;
  MyShoppingCartsScreen({Key key, this.userId}) : super(key: key);
  @override
  _MyShoppingCartsScreenState createState() => _MyShoppingCartsScreenState();
}

class _MyShoppingCartsScreenState extends State<MyShoppingCartsScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final FirebaseFirestore db = FirebaseFirestore.instance;

  final FirebaseStorage storage = FirebaseStorage.instance;

  CollectionReference shoppingCart =
      FirebaseFirestore.instance.collection('shopping cart');

  NUSellUser user = NUSellUser();
  List<String> postAddresses = [];
  List postImages = [];
  String postProductName;
  int postPrice;

  getImage(imgArr) {
    if (imgArr.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Image.asset(
          'assets/images/defaultPreview.png',
          fit: BoxFit.fitHeight,
          width: 60,
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: CachedNetworkImage(
          imageUrl: imgArr[0],
          fit: BoxFit.fitWidth,
          width: 60,
        ),
      );
    }
  }

  _getMyPosts() async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await shoppingCart.doc(widget.userId).get();
    //print(doc.data()['shopping cart']);
    postAddresses = List.from(doc.data()['shopping cart']);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userId)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return Text("Loading");
          // }

          return Scaffold(
            appBar: AppBar(
              title: Text('Liked products'),
              leading: BackButton(
                color: Colors.black,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: Container(
                // padding: EdgeInsets.only(
                //     left: 10, right: 10, top: 60, bottom: 90),
                child: FutureBuilder<Object>(
                    future: _getMyPosts(),
                    builder: (context, snapshot) {
                      if (postAddresses.length == 0) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                              child: Text(
                            'Your shopping cart is empty for now.',
                            style: TextStyle(fontSize: 16),
                          )),
                        );
                      }
                      return ListView(
                        scrollDirection: Axis.vertical,
                        padding: const EdgeInsets.all(8),
                        shrinkWrap: true,
                        children: postAddresses.map((docId) {
                          return FutureBuilder<DocumentSnapshot>(
                              future: db.collection("posts").doc(docId).get(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                                Map<String, dynamic> post =
                                    snapshot.data.data();
                                return GestureDetector(
                                  onTap: () {
                                    if (auth.currentUser == null) {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginScreen()));
                                    } else {
                                      if (post == null) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return popUp(
                                                title:
                                                    "The seller's account has been disabled.",
                                                confirmAction: () {
                                                  Navigator.of(context).pop();
                                                },
                                                cancelButton: false,
                                              );
                                            });
                                      } else if (post["status"] == "Selling") {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProductInfoScreen(
                                                        product: docId)));
                                      } else if (post["status"] == "Deleted") {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return popUp(
                                                title:
                                                    "This post was deleted by the seller.",
                                                subtitle:
                                                    "Contact the seller for more information.",
                                                confirmText: "Contact seller",
                                                confirmAction: () async {
                                                  var docID;
                                                  String seller = post["user"];
                                                  if (seller.compareTo(
                                                          widget.userId) <
                                                      0) {
                                                    docID = seller +
                                                        "_" +
                                                        widget.userId;
                                                  } else {
                                                    docID = widget.userId +
                                                        "_" +
                                                        seller;
                                                  }
                                                  String sellerName;
                                                  db
                                                      .collection("users")
                                                      .doc(seller)
                                                      .get()
                                                      .then((doc) =>
                                                          sellerName =
                                                              doc["username"])
                                                      .then((doc) =>
                                                          Navigator.of(context)
                                                              .pop())
                                                      .then((doc) => Navigator
                                                              .of(context)
                                                          .push(
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ContactSellerScreen(
                                                                            chatID:
                                                                                docID,
                                                                            theOtherUserName:
                                                                                sellerName,
                                                                          ))));
                                                },
                                              );
                                            });
                                      }
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: (post == null ||
                                                post["status"] != "Selling")
                                            ? Colors.grey
                                            : Color.fromRGBO(242, 195, 71, 1),
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 0, 16, 0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.orange,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: post == null
                                                  ? null
                                                  : getImage(post['images']),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(20.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    post == null
                                                        ? "Item is not available"
                                                        : "${post['productName']}",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    post == null
                                                        ? ""
                                                        : "${post['price']}",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  Text(
                                                    post == null ||
                                                            post["status"] !=
                                                                "Selling"
                                                        ? "Unavailable"
                                                        : "",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                                icon: Icon(Icons.delete),
                                                onPressed: () {
                                                  shoppingCart
                                                      .doc(widget.userId)
                                                      .update({
                                                    "shopping cart":
                                                        FieldValue.arrayRemove(
                                                            [docId])
                                                  });
                                                })
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              });
                        }).toList(),
                      );
                    })),
          );
        });
  }
}
