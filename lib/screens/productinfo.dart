import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orbital2796_nusell/models/chat.dart';
import 'package:orbital2796_nusell/screens/editProductForm.dart';
import 'package:orbital2796_nusell/screens/contactSeller.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:orbital2796_nusell/screens/sellerProfile.dart';
import 'package:orbital2796_nusell/screens/shoppingCarts.dart';
import 'package:orbital2796_nusell/services/auth.dart';

class ProductInfoScreen extends StatefulWidget {
  final String product;
  ProductInfoScreen({Key key, this.product}) : super(key: key);

  @override
  State<ProductInfoScreen> createState() => _ProductInfoScreenState();
}

class _ProductInfoScreenState extends State<ProductInfoScreen> {
  var userId;

  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  CollectionReference users = FirebaseFirestore.instance.collection('users');
  List<String> shoppingCarts = [];

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
    var img;
    if (imgArr.isEmpty) {
      img =
          "https://firebasestorage.googleapis.com/v0/b/orbital-test-4e374.appspot.com/o/productpics%2Fdefault%20image.png?alt=media&token=1be9ee11-e256-46f8-81b2-41f1181e44cd";
    } else {
      img = imgArr[index];
    }
    return Column(
      children: [
        Container(
          height: 300,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Listener(
                  onPointerUp: previousPage, child: Icon(Icons.arrow_back_ios)),
              InkWell(
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
                                Image.network(img),
                              ],
                            ),
                          ),
                          insetPadding: EdgeInsets.all(0),
                        );
                      });
                },
                child: Image.network(
                  img,
                  fit: BoxFit.fitWidth,
                  width: 0.7 * MediaQuery.of(context).size.width,
                ),
              ),
              Listener(
                  onPointerUp: nextPage, child: Icon(Icons.arrow_forward_ios)),
            ],
          ),
        ),
        Container(
            margin: EdgeInsets.only(top: 10),
            child:
                Text(this.len > 0 ? "${this.index + 1} / ${this.len}" : "0/0")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    this.userId = auth.currentUser.uid;

    interactions(String seller, String user) {
      if (seller == user) {
        return Row(
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
                onPressed: () async {
                  DocumentReference docRef =
                      db.collection("posts").doc(widget.product);
                  var doc = await docRef.get();
                  List<dynamic> images = doc["images"];
                  for (var img in images) {
                    storage.refFromURL(img).delete();
                  }
                  docRef.delete();
                  db.collection("users").doc(user).update({
                    "posts": FieldValue.arrayRemove([widget.product])
                  });
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(255, 88, 68, 1),
                ),
                child: Text("Delete")),
          ],
        );
      } else {
        Chat chat = new Chat(seller, user);
        return FutureBuilder(
            future: db.collection("posts").doc(widget.product).get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              Map<String, dynamic> post = snapshot.data.data();
              return Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      String docID = seller + '_' + user;
                      db.collection("chats").doc(docID).get()
                        .then((snapshot) => {
                          if (!snapshot.exists) {
                            db.collection("chats").doc(docID).set(chat.toMap()),
                            db.collection("users").doc(seller).update({"chats": FieldValue.arrayUnion([docID])}),
                            db.collection("users").doc(user).update({"chats": FieldValue.arrayUnion([docID])}),
                          }
                      });
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              ContactSellerScreen(chatID: docID)));
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(100, 170, 255, 1),
                    ),
                    child: Text("Contact the seller"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              SellerProfileScreen(sellerId: post['user'])));
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(100, 170, 255, 1),
                    ),
                    child: Text("See the seller's profile"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                          icon: Icon(Icons.shopping_cart),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MyShoppingCartsScreen(
                                      userId: AuthService().getCurrentUID(),
                                    )));
                          }),
                      ElevatedButton(
                        onPressed: () {
                          users.doc(AuthService().getCurrentUID()).update({
                            'shopping carts':
                                FieldValue.arrayUnion([widget.product]),
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromRGBO(100, 170, 255, 1),
                        ),
                        child: Text("Add to cart"),
                      ),
                    ],
                  )
                ],
              );
            });
      }
    }

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Colors.black,
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 30, right: 30),
        child: FutureBuilder<DocumentSnapshot>(
          future: db.collection("posts").doc(widget.product).get(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            Map<String, dynamic> post = snapshot.data.data();
            len = post['images'].length;
            return ListView(
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
                    return InkWell(
                      onTap: () {
                        if (post['user'] == this.userId) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ProfileScreen()));
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
                                child: Image.network(
                                  "${user["avatarUrl"]}",
                                  height: 60,
                                  width: 60,
                                  fit: BoxFit.fitWidth,
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

                // Time and Location
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
                        margin: EdgeInsets.only(left: 15),
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
                interactions(post['user'], this.userId),
              ],
            );
          },
        ),
      ),
    );
  }
}
