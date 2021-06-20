import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:orbital2796_nusell/screens/productinfo.dart';
import 'package:orbital2796_nusell/services/search.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({Key key}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final FirebaseFirestore db = FirebaseFirestore.instance;

  CollectionReference searchHist =
      FirebaseFirestore.instance.collection('searchHistory');

  List<Map<String, dynamic>> queryResultSet = [];
  var tempSearchStore = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

  initiateSearch(String value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    } else {
      var uncapitalisedValue =
          value.substring(0, 1).toLowerCase() + value.substring(1);

      if (queryResultSet.length == 0 && value.length == 1) {
        SearchService().searchByName(value).then((docs) {
          for (int i = 0; i < docs.size; ++i) {
            Map<String, dynamic> data = docs.docs[i].data();
            queryResultSet.add(data);
            setState(() {
              tempSearchStore.add(queryResultSet[i]);
            });
          }
        });
      } else {
        tempSearchStore = [];
        queryResultSet.forEach((element) {
          String name = element['productName'];
          if (name.toLowerCase().startsWith(uncapitalisedValue)) {
            setState(() {
              tempSearchStore.add(element);
            });
          }
        });
      }
    }
    if (tempSearchStore.length == 0 && value.length > 1) {
      setState(() {});
    }
  }

  fullTextSearch(String value) {
    setState(() {
      searchHistory = [];
    });
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    } else {
      var uncapitalisedValue = value.toLowerCase().trim();

      if (queryResultSet.length == 0 && value.length == 1) {
        SearchService().fullTextSearch(value).then((docs) {
          for (int i = 0; i < docs.size; ++i) {
            Map<String, dynamic> data = docs.docs[i].data();
            queryResultSet.add(data);
            setState(() {
              tempSearchStore.add(queryResultSet[i]);
            });
          }
        });
      } else {
        tempSearchStore = [];
        queryResultSet.forEach((element) {
          String name = element['nameForSearch'].toString().toLowerCase();
          if (name.trim().contains(uncapitalisedValue)) {
            setState(() {
              tempSearchStore.add(element);
            });
          }
        });
      }
    }
    if (tempSearchStore.length == 0 && value.length > 1) {
      setState(() {});
    }
  }

  List<Map<String, dynamic>> dataStore = [];
  var searchStore = [];

  searchByWord(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }
    setState(() {
      searchHistory = [];
      tempSearchStore = [];
    });
    if (dataStore.length == 0) {
      SearchService().fullTextSearch(value).then((docs) {
        for (int i = 0; i < docs.size; ++i) {
          Map<String, dynamic> data = docs.docs[i].data();
          dataStore.add(data);
          //print(dataStore.length);
        }
        compareName(value);
      });
    }
    compareName(value);
  }

  compareName(value) {
    dataStore.forEach((element) {
      String name = element['nameForSearch'].toString().toLowerCase();
      if (name.trim().contains(value)) {
        setState(() {
          tempSearchStore.add(element);
          //print(tempSearchStore.length);
        });
      }
    });
  }

  List<String> searchHistory = [];
  List<String> toStore = [];
  String userId = FirebaseAuth.instance.currentUser.uid;

  storeSearchHistory(String value) {
    var options = SetOptions(merge: true);
    bool contains = false;
    for (var hist in toStore) {
      if (value == hist) contains = true;
    }
    if (!contains) toStore.add(value);
    searchHist.doc(userId).set({'searchHistory': toStore}, options);
  }

  readSearchHistory() async {
    if (searchField.text == "") {
      setState(() {
        searchHistory = [];
      });
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await searchHist.doc(userId).get();
      var stored = doc.data()['searchHistory'];
      for (var hist in stored) {
        searchHistory.add(hist);
      }
      toStore = searchHistory;
    }
  }

  TextEditingController searchField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(242, 195, 71, 1),
        elevation: 0,
        title: Container(
          margin: EdgeInsets.only(left: 10, right: 40),
          child: TextField(
            controller: searchField,
            onChanged: (val) {
              fullTextSearch(val);
            },
            onSubmitted: (val) {
              searchByWord(val);
              storeSearchHistory(val);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(20),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              hintText: "Search",
              isDense: true,
              contentPadding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
              fillColor: Color.fromRGBO(249, 248, 253, 1),
              filled: true,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          FutureBuilder(
              future: readSearchHistory(),
              builder: (context, snapshot) {
                return ListView(
                  primary: false,
                  shrinkWrap: true,
                  children: searchHistory.map((element) {
                    return ElevatedButton(
                      onPressed: () {
                        searchField.text = element;
                      },
                      child: Text(element),
                    );
                  }).toList(),
                );
              }),
          SizedBox(
            height: 10.0,
          ),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            primary: false,
            shrinkWrap: true,
            children: tempSearchStore.map((element) {
              //return buildResultCard(element);
              return InkWell(
                onTap: () {
                  if (auth.currentUser == null) {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            ProductInfoScreen(product: element['productId'])));
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
                        child: getImage(element['images']),
                      ),
                      Text(
                        "${element['productName']}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "${element['price']}",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}

Widget buildResultCard(data) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    elevation: 2,
    child: Container(
      child: Center(
        child: Text(data['productName']),
      ),
    ),
  );
}
