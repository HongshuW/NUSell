import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/screens/productinfo.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:orbital2796_nusell/services/auth.dart';

class OffersMadeScreen extends StatefulWidget {
  const OffersMadeScreen({Key key}) : super(key: key);

  @override
  _OffersMadeScreenState createState() => _OffersMadeScreenState();
}

class _OffersMadeScreenState extends State<OffersMadeScreen> {
  CollectionReference offersMade = FirebaseFirestore.instance
      .collection('users')
      .doc(AuthService().getCurrentUID())
      .collection('offersMade');
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offers made'),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ProfileScreen()));
          },
        ),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
            stream: offersMade.snapshots(),
            builder: (context, querySnapshot) {
              if (querySnapshot.connectionState == ConnectionState.waiting) {
                return Text('Not yet');
              }
              return ListView(
                  children: querySnapshot.data.docs.map((doc) {
                List pricesOffered = doc['price'];
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.lightGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: StreamBuilder<DocumentSnapshot>(
                        stream: posts.doc(doc.id).snapshots(),
                        builder: (context2, snapshot2) {
                          if (!snapshot2.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }
                          Map<String, dynamic> post = snapshot2.data.data();
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${doc['status']}',
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                                doc['status'] == 'Accepted'
                                    ? Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Text(
                                            'Please contact the seller to meet up or mail to receive the item'),
                                      )
                                    : Container(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Product: ${post['productName']}',
                                      style: TextStyle(fontSize: 22),
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProductInfoScreen(
                                                          product: doc.id)));
                                        },
                                        child: Text('View'))
                                  ],
                                ),
                                ListView(
                                  shrinkWrap: true,
                                  children: pricesOffered
                                      .map((price) =>
                                          Text('Price offered: ${price}'))
                                      .toList(),
                                ),
                              ],
                            ),
                          );
                        }),
                  ),
                );
              }).toList());
            }),
      ),
    );
  }
}
