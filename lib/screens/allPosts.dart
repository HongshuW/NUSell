import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orbital2796_nusell/providers/filtersProvider.dart';
import 'package:orbital2796_nusell/providers/postsProvider.dart';
import 'package:orbital2796_nusell/screens/productinfo.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class allPosts extends StatefulWidget {
  final bool hasPagination;
  allPosts({Key key, this.hasPagination}) : super(key: key);

  @override
  _allPostsState createState() => _allPostsState();
}

class _allPostsState extends State<allPosts> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // a list of document snapshots, each represents a product.
  List<DocumentSnapshot> products = [];
  // whether the page is loading.
  bool isLoading = false;
  // whether there are more posts in the database.
  bool hasMore = true;
  // number of posts on each load.
  int numPerPage = 6;
  DocumentSnapshot lastDoc;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.hasPagination) {
      getPosts();
      // load more when the end of the screen is reached.
      _scrollController.addListener(() {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;
        double criteria = 2;
        if (maxScroll - currentScroll < criteria) {
          getPosts();
        }
      });
    }
  }

  // Load posts (depend on the current state) from database.
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
    if (imgArr.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
        child: Image.asset(
          'assets/images/defaultPreview.png',
          fit: BoxFit.fitWidth,
          width: 200,
        ),
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

  @override
  Widget build(BuildContext context) {
    // Providers
    final filterState = Provider.of<filtersProvider>(context);
    final postsState = Provider.of<postsProvider>(context);

    if (widget.hasPagination) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
                    children: products.map<Widget>((doc) {
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
        ]),
      );
    } else {
      return StreamBuilder(
          stream: postsState.snapshot.snapshots(),
          builder: (context, snapshot) {
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
                      .where((doc) => DateTime.fromMillisecondsSinceEpoch(
                              doc["time"].millisecondsSinceEpoch)
                          .isAfter(DateTime.fromMillisecondsSinceEpoch(
                              filterState
                                  .timeRequested.millisecondsSinceEpoch)))
                      .where((doc) => filterState.categorySelected
                          .contains(doc["category"]))
                      .where((doc) =>
                          filterState.locationSelected.contains(doc["location"]))
                      .where((doc) => doc["price"] < filterState.range[1] && doc["price"] >= filterState.range[0])
                      .where((doc) => doc["sellerScore"] < filterState.range2[1] && doc["sellerScore"] >= filterState.range2[0])
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
                ));
          });
    }
  }
}
