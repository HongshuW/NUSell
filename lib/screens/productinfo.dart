import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Listener(
                  onPointerUp: previousPage, child: Icon(Icons.arrow_back_ios)),
              Image.network(
                img,
                fit: BoxFit.fitWidth,
                width: 200,
              ),
              Listener(
                  onPointerUp: nextPage, child: Icon(Icons.arrow_forward_ios)),
            ],
          ),
        ),
        Text(this.len > 0 ? "${this.index + 1} / ${this.len}" : "0/0"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    this.userId = auth.currentUser.uid;

    interactions(String seller, String user) {
      if (seller == user) {
        return Column(
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
                  db.collection("posts").doc(widget.product).delete();
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
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              ContactSellerScreen(seller: post['user'])));
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
        padding: EdgeInsets.all(30),
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
                            Text("${user["username"]}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Time posted
                Row(
                  children: [
                    Text(
                        "${DateTime.fromMillisecondsSinceEpoch(post["time"].millisecondsSinceEpoch)}"
                            .substring(0, 10)),
                  ],
                ),

                // Product Name
                Row(
                  children: [
                    Icon(
                      Icons.article,
                    ),
                    Text("${post['productName']}"),
                  ],
                ),

                // Price
                Row(
                  children: [
                    Icon(Icons.attach_money),
                    Text("${post['price']}"),
                  ],
                ),

                // Location
                Row(
                  children: [
                    Icon(Icons.location_on),
                    Text("${post['location']}"),
                  ],
                ),

                // Description
                Text("\nDescription: \n${post['description']} \n"),

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
