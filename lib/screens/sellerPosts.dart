import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:orbital2796_nusell/screens/productinfo.dart';
import 'package:orbital2796_nusell/subProject/custom_radio_grouped_button/custom_radio_grouped_button.dart';

class SellerPostsScreen extends StatefulWidget {
  final String userId;
  const SellerPostsScreen({Key key, this.userId}) : super(key: key);

  @override
  _SellerPostsScreenState createState() => _SellerPostsScreenState();
}

class _SellerPostsScreenState extends State<SellerPostsScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final FirebaseFirestore db = FirebaseFirestore.instance;

  final FirebaseStorage storage = FirebaseStorage.instance;

  List<String> postAddresses = [];
  List postImages = [];
  String postProductName;
  int postPrice;

  String status = "Selling";

  // Display the first image of a post.
  getImage(imgArr) {
    if (imgArr.isEmpty) {
      return Image.asset(
        'assets/images/defaultPreview.png',
        fit: BoxFit.fitHeight,
        width: 200,
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
        child: CachedNetworkImage(
          imageUrl: imgArr[0],
          fit: BoxFit.fitWidth,
          width: 200,
        ),
      );
    }
  }

  _getMyPosts() async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('myPosts')
        .doc(widget.userId)
        .get();
    // user = NUSellUser.fromJson(doc.data());

    postAddresses = List.from(doc.data()['myPosts']);
  }

  @override
  Widget build(BuildContext context) {
    interactions(String seller, String user) {
      if (seller == user) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text('You have not posted anything yet.')),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Text('The user has not posted anything yet.')),
        );
      }
    }

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

          return Container(
            padding: EdgeInsets.only(left: 10, right: 10, top: 60, bottom: 90),
            child: FutureBuilder<Object>(
                future: _getMyPosts(),
                builder: (context, snapshot) {
                  if (postAddresses.length == 0) {
                    return interactions(
                        widget.userId, FirebaseAuth.instance.currentUser.uid);
                  }
                  return StaggeredGridView.countBuilder(
                    crossAxisCount: 2,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 0,
                    shrinkWrap: true,
                    itemCount: postAddresses.length,
                    staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                    itemBuilder: (context, index) => ConstrainedBox(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.23,
                          minHeight: 0),
                      child: FutureBuilder<DocumentSnapshot>(
                          future: db
                              .collection("posts")
                              .doc(postAddresses[index])
                              .get(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }
                            Map<String, dynamic> post = snapshot.data.data();
                            if (post["status"] != this.status) {
                              return Container(height: 0, width: 0);
                            }
                            return InkWell(
                              onTap: () {
                                if (auth.currentUser == null) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => LoginScreen()));
                                } else {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ProductInfoScreen(
                                          product: postAddresses[index])));
                                }
                              },
                              child: Card(
                                child: Column(
                                  children: <Widget>[
                                    Expanded(
                                      child: getImage(post['images']),
                                    ),
                                    Text(
                                      "${post['productName']}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "${post['price']}",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                    // children: postAddresses.map((docId) {
                    //   return FutureBuilder<DocumentSnapshot>(
                    //       future: db.collection("posts").doc(docId).get(),
                    //       builder: (context, snapshot) {
                    //         if (!snapshot.hasData) {
                    //           return Center(
                    //               child: CircularProgressIndicator());
                    //         }
                    //         Map<String, dynamic> post = snapshot.data.data();
                    //         if (post["status"] != this.status) {
                    //           return Container(height: 0, width: 0);
                    //         }
                    //         return InkWell(
                    //           onTap: () {
                    //             if (auth.currentUser == null) {
                    //               Navigator.of(context).push(
                    //                   MaterialPageRoute(
                    //                       builder: (context) =>
                    //                           LoginScreen()));
                    //             } else {
                    //               Navigator.of(context).push(
                    //                   MaterialPageRoute(
                    //                       builder: (context) =>
                    //                           ProductInfoScreen(
                    //                               product: docId)));
                    //             }
                    //           },
                    //           child: Card(
                    //             child: Column(
                    //               children: <Widget>[
                    //                 Expanded(
                    //                   child: getImage(post['images']),
                    //                 ),
                    //                 Text(
                    //                   "${post['productName']}",
                    //                   style: TextStyle(
                    //                     fontWeight: FontWeight.bold,
                    //                     fontSize: 16,
                    //                   ),
                    //                 ),
                    //                 Text(
                    //                   "${post['price']}",
                    //                   style: TextStyle(
                    //                     fontSize: 16,
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         );
                    //       });
                    // }).toList(),
                  );
                }),
          );
        });
  }
}
