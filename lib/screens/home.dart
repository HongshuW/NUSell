import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/providers/userInfoProvider.dart';
import 'package:orbital2796_nusell/screens/post.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:provider/provider.dart';
import 'package:orbital2796_nusell/screens/login.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  getImage(imgArr) async {
    var path;
    if (imgArr.isEmpty) {
      path = 'productpics/default.png';
    } else {
      path = imgArr[0];
    }
    var img = await storage.ref().child(path).getDownloadURL();
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
    final userinfoProvider =
        Provider.of<userInfoProvider>(context, listen: false);
    return Scaffold(
      //a collection of three floating action buttons, on pressed will
      //turn to another page
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Container(
          margin: EdgeInsets.only(left: 40, right: 40),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(20),
              ),
              focusedBorder:OutlineInputBorder(
                borderSide: BorderSide(color: Color.fromRGBO(252, 228, 70, 1)),
                borderRadius: BorderRadius.circular(20),
              ),
              hintText: "Search",
              isDense: true,
              contentPadding: EdgeInsets.only(left: 10, top: 5, bottom: 5),
            ),
          ),
        ),
      ),
      body: Container(
        color: Color.fromRGBO(240, 240, 240, 1),
        padding: EdgeInsets.only(left: 10, right: 10, top: 30, bottom: 30),
        child: StreamBuilder(
          stream: db.collection("posts").snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true,
              children: snapshot.data.docs.map((doc) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                    child: Column(children: <Widget>[
                        Expanded(
                          child: FutureBuilder(
                            future: getImage(doc["images"]),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return snapshot.data;
                            },
                          ),
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
                            fontSize: 16,
                          ),
                        ),
                      ],),
                );
              }).toList(),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              heroTag: "home",
              onPressed: () {},
              child: Icon(Icons.house),
            ),
            FloatingActionButton(
              heroTag: "post",
              onPressed: () {
                if (auth.currentUser == null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => LoginScreen()));
                } else {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => PostScreen()));
                }
              },
              child: Icon(Icons.add),
            ),
            FloatingActionButton(
              heroTag: "profile",
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ProfileScreen()));
              },
              child: Icon(Icons.person),
            )
          ],
        ),
      ),
    );
  }
}