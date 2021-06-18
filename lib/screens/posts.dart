import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:orbital2796_nusell/screens/productinfo.dart';

class AllPostsScreen extends StatefulWidget {
  final String userId;
  AllPostsScreen({Key key, this.userId}) : super(key: key);
  @override
  _AllPostsScreenState createState() => _AllPostsScreenState();
}

class _AllPostsScreenState extends State<AllPostsScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final FirebaseFirestore db = FirebaseFirestore.instance;

  final FirebaseStorage storage = FirebaseStorage.instance;

  List<String> postAddresses = [];
  List postImages = [];
  String postProductName;
  int postPrice;

  getImage(imgArr) {
    var img;
    if (imgArr.isEmpty) {
      img =
          'https://firebasestorage.googleapis.com/v0/b/orbital-test-4e374.appspot.com/o/productpics%2Fdefault.png?alt=media&token=c1100242-206c-44d9-a51b-181937932156';
    } else {
      img = imgArr[0];
    }
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
      child: Image.network(
        img,
        fit: BoxFit.fitWidth,
        width: 200,
      ),
    );
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
              padding:
                  EdgeInsets.only(left: 10, right: 10, top: 60, bottom: 90),
              child: FutureBuilder<Object>(
                  future: _getMyPosts(),
                  builder: (context, snapshot) {
                    return GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      shrinkWrap: true,
                      children: postAddresses.map((docId) {
                        return FutureBuilder<DocumentSnapshot>(
                            future: db.collection("posts").doc(docId).get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              Map<String, dynamic> post = snapshot.data.data();
                              return InkWell(
                                onTap: () {
                                  if (auth.currentUser == null) {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                LoginScreen()));
                                  } else {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProductInfoScreen(
                                                    product: docId)));
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
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
                            });
                      }).toList(),
                    );
                  }));
        });
  }
}
