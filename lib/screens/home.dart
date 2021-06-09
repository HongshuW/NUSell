import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:orbital2796_nusell/providers/userInfoProvider.dart';
import 'package:orbital2796_nusell/screens/post.dart';
import 'package:orbital2796_nusell/screens/productinfo.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:provider/provider.dart';
import 'package:orbital2796_nusell/screens/login.dart';

class HomeScreen extends StatelessWidget {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

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
    final userinfoProvider =
        Provider.of<userInfoProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromRGBO(242, 195, 71, 1),
        elevation: 0,
        title: Container(
          margin: EdgeInsets.only(left: 40, right: 40),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(20),
              ),
              focusedBorder:OutlineInputBorder(
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.16, 0.16],
            colors: [
              Color.fromRGBO(242, 195, 71, 1),
              Color.fromRGBO(252, 228, 70, 1),
              Color.fromRGBO(249, 248, 253, 1),
            ],
          ),
        ),
        // color: Color.fromRGBO(240, 240, 240, 1),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: CustomRadioButton(
                elevation: 0,
                padding: 0,
                enableShape: true,
                enableButtonWrap: true,
                width: 120,
                wrapAlignment: WrapAlignment.center,
                buttonLables: [
                  'Time Posted',
                  'Category',
                  'Location',
                  'Price',
                ],
                buttonValues: [
                  'Time Posted',
                  'Category',
                  'Location',
                  'Price',
                ],
                buttonTextStyle: ButtonTextStyle(
                    selectedColor: Color.fromRGBO(190, 140, 90, 1),
                    unSelectedColor: Colors.white,
                    textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                    ),
                ),
                radioButtonValue: (value) {
                  print(value);
                },
                unSelectedColor: Colors.transparent,
                selectedColor: Color.fromRGBO(250, 190, 90, 1),
                unSelectedBorderColor: Colors.white,
                selectedBorderColor: Color.fromRGBO(190, 140, 90, 1),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 10, right: 10, top: 60, bottom: 90),
              child: StreamBuilder(
                stream: db.collection("posts").orderBy("time", descending: true).snapshots(),
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
                                    fontSize: 16,
                                  ),
                                ),
                              ],),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      //a collection of three floating action buttons, on pressed will
      //turn to another page
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              heroTag: "home",
              onPressed: () {},
              child: Icon(Icons.house, color: Colors.white),
              backgroundColor: Color.fromRGBO(247, 215, 140, 1),
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
              child: Icon(Icons.add, color: Colors.white),
              backgroundColor: Color.fromRGBO(242, 195, 71, 1),
            ),
            FloatingActionButton(
              heroTag: "profile",
              onPressed: () {
                if (auth.currentUser == null) {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginScreen()));
                } else {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ProfileScreen()));
                }
              },
              child: Icon(Icons.person, color: Colors.white,),
              backgroundColor: Color.fromRGBO(242, 195, 71, 1),
            )
          ],
        ),
      ),
    );
  }
}