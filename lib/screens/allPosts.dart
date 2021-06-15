import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orbital2796_nusell/providers/filtersProvider.dart';
import 'package:orbital2796_nusell/screens/productinfo.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:provider/provider.dart';

class allPosts extends StatefulWidget {
  allPosts({Key key}) : super(key: key);

  @override
  _allPostsState createState() => _allPostsState();
}

class _allPostsState extends State<allPosts> {
  // firebase fields
  final FirebaseAuth auth = FirebaseAuth.instance;

  // pagination fields
  List<DocumentSnapshot> products = [];
  bool isLoading = false;
  bool hasMore = true;
  int numPerPage = 6;
  DocumentSnapshot lastDoc;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getPosts();
    _scrollController.addListener(() {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double criteria = MediaQuery.of(context).size.height * 0.2;
      if (maxScroll - currentScroll < criteria) {
        getPosts();
      }
    });
  }

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
          .collection("posts")
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
    products.addAll(querySnapshot.docs);
    setState(() {
      isLoading = false;
    });
  }

  // Display the first image of a post.
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
        topLeft: Radius.circular(5),
        topRight: Radius.circular(5),
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
    // Providers
    final filterState = Provider.of<filtersProvider>(context);

    return Container(
      height: 400,
      margin: EdgeInsets.all(20),
      child: Column(children: [
        Expanded(
          child: products.length == 0
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : GridView.count(
                  controller: _scrollController,
                  crossAxisCount: 2,
                  crossAxisSpacing: 5,
                  mainAxisSpacing: 5,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: ScrollPhysics(),
                  children: products
                      .where((doc) =>
                          doc["time"].millisecondsSinceEpoch >=
                          filterState.timeRequested.millisecondsSinceEpoch)
                      .where((doc) => filterState.categorySelected
                          .contains(doc["category"]))
                      .where((doc) => filterState.locationSelected
                          .contains(doc["location"]))
                      .where((doc) =>
                          doc["price"] < filterState.range[1] &&
                          doc["price"] >= filterState.range[0])
                      .map<Widget>((doc) {
                    return InkWell(
                      onTap: () {
                        if (auth.currentUser == null) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ProductInfoScreen(product: doc.id)));
                        }
                      },
                      child: Card(
                        child: Column(
                          children: <Widget>[
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
                                  height: 1.5),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
        isLoading
            ? Container(
                margin: EdgeInsets.all(5),
                child: Text(
                  "loading...",
                  style: TextStyle(
                    color: Color.fromRGBO(252, 228, 70, 1),
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1,
                  ),
                ),
              )
            : Container()
      ]),
    );
  }
}
