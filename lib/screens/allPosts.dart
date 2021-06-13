import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orbital2796_nusell/providers/filtersProvider.dart';
import 'package:orbital2796_nusell/providers/postsProvider.dart';
import 'package:orbital2796_nusell/screens/productinfo.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:provider/provider.dart';

class allPosts extends StatefulWidget {
  allPosts({Key key}) : super(key: key);

  @override
  _allPostsState createState() => _allPostsState();
}

class _allPostsState extends State<allPosts> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getImage(imgArr) {
    var img;
    if (imgArr.isEmpty) {
      img = 'https://firebasestorage.googleapis.com/v0/b/orbital-test-4e374.appspot.com/o/productpics%2Fdefault.png?alt=media&token=c1100242-206c-44d9-a51b-181937932156';
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

  @override
  Widget build(BuildContext context) {
    final posts = Provider.of<postsProvider>(context);
    final filterState = Provider.of<filtersProvider>(context);

    return StreamBuilder(
      stream: posts.snapshot,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Container(
          margin: EdgeInsets.all(20),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: ScrollPhysics(),
            children: snapshot.data.docs
                .where((doc) => doc["price"] < filterState.range[1]
                && doc["price"] >= filterState.range[0])
                .map((doc) {
                  return InkWell(
                    onTap: () {
                      if (auth.currentUser == null) {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => LoginScreen()));
                      } else {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => ProductInfoScreen(product: doc.id)));
                      }
                      },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(children: <Widget>[
                        Expanded(
                          child: getImage(doc["images"]),
                        ),
                        Text(
                          "${doc["productName"]}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "\$${doc["price"].toString()}",
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: 17,
                            height: 1.5
                          ),
                        ),
                      ],),
                    ),
                  );
                }).toList(),
          ),
        );
        },
    );
  }
}