import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:orbital2796_nusell/screens/productinfo.dart';
import 'package:orbital2796_nusell/services/search.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({Key key}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final FirebaseFirestore db = FirebaseFirestore.instance;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text('Search'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (val) {
                fullTextSearch(val);
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
