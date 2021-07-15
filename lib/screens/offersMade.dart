import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/screens/productinfo.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:orbital2796_nusell/screens/review.dart';
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
            //Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ProfileScreen()));
          },
        ),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
            stream: offersMade.orderBy('time', descending: true).snapshots(),
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
                                        child: Column(
                                          children: [
                                            Text(
                                                'Please contact the seller to meet up or mail to receive the item'),
                                            Text(
                                                'Price accepted: ${doc['priceAccepted']}')
                                          ],
                                        ),
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
                                doc['status'] == 'Declined'
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                            'Sorry, the seller has accepted offer by another user'),
                                      )
                                    : doc['buyerReceivedProduct'] == false
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    'I have received the product'),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      offersMade
                                                          .doc(doc.id)
                                                          .set(
                                                              {
                                                            'buyerReceivedProduct':
                                                                true
                                                          },
                                                              SetOptions(
                                                                  merge: true));
                                                    },
                                                    child: Text('Confirm'))
                                              ],
                                            ),
                                          )
                                        : doc['reviewDone'] == false
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text(
                                                            'Transaction completed!'),
                                                        Text(
                                                            'Write a review for the seller')
                                                      ],
                                                    ),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pushReplacement(
                                                                  MaterialPageRoute(
                                                                      builder: (context) =>
                                                                          ReviewScreen(
                                                                            product:
                                                                                doc.id,
                                                                            seller:
                                                                                post['user'],
                                                                          )));
                                                        },
                                                        child: Text('Go!'))
                                                  ],
                                                ),
                                              )
                                            : Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                        'Transaction completed!'),
                                                    Text(
                                                        'Thanks for writing the review!')
                                                  ],
                                                ),
                                              )
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
