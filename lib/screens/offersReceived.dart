import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/models/chat.dart';
import 'package:orbital2796_nusell/screens/contactSeller.dart';
import 'package:orbital2796_nusell/screens/productinfo.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:orbital2796_nusell/services/auth.dart';

class OffersReceivedScreen extends StatefulWidget {
  const OffersReceivedScreen({
    Key key,
  }) : super(key: key);

  @override
  _OffersReceivedScreenState createState() => _OffersReceivedScreenState();
}

class _OffersReceivedScreenState extends State<OffersReceivedScreen> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  CollectionReference offersReceived = FirebaseFirestore.instance
      .collection('users')
      .doc(AuthService().getCurrentUID())
      .collection('offersReceived');
  CollectionReference offersMade = FirebaseFirestore.instance
      .collection('users')
      .doc(AuthService().getCurrentUID())
      .collection('offersMade');
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  List<String> offerFromUsers;

  ScrollController _scrollController = new ScrollController();
  // var offers;
  // setOffers() async {
  //   offers = await offersReceived.get();
  // }

  @override
  Widget build(BuildContext context) {
    // setOffers();
    // offers = offersReceived.get();
    // print(offers.toString());
    return Scaffold(
      appBar: AppBar(
        title: Text('Offers Received'),
        leading: BackButton(
          onPressed: () {
            //Navigator.of(context).pop();
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => ProfileScreen()));
          },
        ),
      ),
      body: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 0, 0),
            child: Text(
              'Waiting for acceptance',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
              stream: offersReceived.snapshots(),
              builder: (context, querySnapshot) {
                if (querySnapshot.connectionState == ConnectionState.waiting) {
                  return Text('Not yet');
                }
                return Container(
                  height: 200,
                  child: ListView(
                    shrinkWrap: true,
                    children: querySnapshot.data.docs.map((doc) {
                      return StreamBuilder<DocumentSnapshot>(
                          stream: posts.doc(doc.id).snapshots(),
                          builder: (context2, snapshot2) {
                            if (!snapshot2.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }
                            Map<String, dynamic> post = snapshot2.data.data();
                            Map<String, dynamic> offers = doc.data();
                            var offer1 = offers['offers'];

                            if (offer1 == 'sold') {
                              return Container(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 4, 4, 4),
                                  child: Text(
                                      'Offer for ${post['productName']} has been accepted'),
                                ),
                              );
                            }
                            List offerList = offers['offers'];

                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Product: ${post['productName']}',
                                        style: TextStyle(fontSize: 22),
                                      ),
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProductInfoScreen(
                                                          product: doc.id)));
                                        },
                                        child: Text('View')),
                                    ListView(
                                      shrinkWrap: true,
                                      children: offerList.map((offer) {
                                        int index = offerList.indexOf(offer);
                                        print(offer.toString());
                                        return StreamBuilder<DocumentSnapshot>(
                                            stream: users
                                                .doc(offer['offerFromUser'])
                                                .snapshots(),
                                            builder: (context3, snapshot3) {
                                              if (!snapshot3.hasData) {
                                                return Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              }
                                              Map<String, dynamic> userDoc =
                                                  snapshot3.data.data();
                                              return Container(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'User ${userDoc['username']} has offered ${offer['priceOffered']}',
                                                        style: TextStyle(
                                                            fontSize: 12),
                                                      ),
                                                      ElevatedButton(
                                                          onPressed: () {
                                                            posts.doc(doc.id).set(
                                                                {
                                                                  'status':
                                                                      'Sold'
                                                                },
                                                                SetOptions(
                                                                    merge:
                                                                        true));
                                                            for (var user
                                                                in offerList) {
                                                              offersMade
                                                                  .doc(doc.id)
                                                                  .set(
                                                                      {
                                                                    'status':
                                                                        'Declined'
                                                                  },
                                                                      SetOptions(
                                                                          merge:
                                                                              true));
                                                            }
                                                            offersReceived
                                                                .doc(doc.id)
                                                                .set(
                                                                    {
                                                                  'status':
                                                                      'Accepted',
                                                                  'userAccepted':
                                                                      offerList
                                                                          .elementAt(
                                                                              index),
                                                                  'time':
                                                                      DateTime
                                                                          .now(),
                                                                  'offers':
                                                                      'sold'
                                                                },
                                                                    SetOptions(
                                                                        merge:
                                                                            true));

                                                            users
                                                                .doc(offer[
                                                                    'offerFromUser'])
                                                                .collection(
                                                                    'offersMade')
                                                                .doc(doc.id)
                                                                .set(
                                                                    {
                                                                  'status':
                                                                      'Accepted',
                                                                  'priceAccepted':
                                                                      offer[
                                                                          'priceOffered'],
                                                                },
                                                                    SetOptions(
                                                                        merge:
                                                                            true));
                                                          },
                                                          child:
                                                              Text('Accept')),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                      }).toList(),
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                    }).toList(),
                  ),
                );
              }),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 15, 0, 0),
            child: Text(
              'Accepted',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 6, 0),
            child: Text(
                'Please contact the buyer to meet up or mail to send the item'),
          ),
          Container(
            height: 230,
            child: StreamBuilder<QuerySnapshot>(
                stream: offersReceived
                    .orderBy('time', descending: true)
                    .snapshots(),
                builder: (context, querySnapshot) {
                  if (querySnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Text('Not yet');
                  }
                  return ListView(
                    shrinkWrap: true,
                    children: querySnapshot.data.docs.map((doc) {
                      return StreamBuilder<DocumentSnapshot>(
                          stream: posts.doc(doc.id).snapshots(),
                          builder: (context2, snapshot2) {
                            if (!snapshot2.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }
                            Map<String, dynamic> post = snapshot2.data.data();
                            Map<String, dynamic> offers = doc.data();
                            Map userAccepted = offers['userAccepted'];

                            if (userAccepted == null) return Container();
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.lightGreen,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Product: ${post['productName']}',
                                        style: TextStyle(fontSize: 22),
                                      ),
                                    ),
                                    ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProductInfoScreen(
                                                          product: doc.id)));
                                        },
                                        child: Text('View')),
                                    StreamBuilder<DocumentSnapshot>(
                                        stream: users
                                            .doc(userAccepted['offerFromUser'])
                                            .snapshots(),
                                        builder: (context, snapshot4) {
                                          if (!snapshot4.hasData) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                          Map<String, dynamic> userDoc2 =
                                              snapshot4.data.data();
                                          String seller =
                                              AuthService().getCurrentUID();
                                          String user =
                                              userAccepted['offerFromUser'];
                                          Chat chat = new Chat([seller, user]);
                                          String docID;
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  '${userDoc2['username']} offered ${userAccepted['priceOffered']}',
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                              ),
                                              //TODO
                                              //Add chat option
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    if (seller.compareTo(user) <
                                                        0) {
                                                      docID =
                                                          seller + "_" + user;
                                                    } else {
                                                      docID =
                                                          user + "_" + seller;
                                                    }
                                                    db
                                                        .collection("chats")
                                                        .doc(docID)
                                                        .get()
                                                        .then((snapshot) => {
                                                              if (!snapshot
                                                                  .exists)
                                                                {
                                                                  db
                                                                      .collection(
                                                                          "chats")
                                                                      .doc(
                                                                          docID)
                                                                      .set(chat
                                                                          .toMap()),
                                                                  db
                                                                      .collection(
                                                                          "myChats")
                                                                      .doc(
                                                                          seller)
                                                                      .get()
                                                                      .then(
                                                                          (sellerSnapshot) =>
                                                                              {
                                                                                if (!sellerSnapshot.exists)
                                                                                  {
                                                                                    db.collection("myChats").doc(seller).set({
                                                                                      "myChats": [docID]
                                                                                    })
                                                                                  }
                                                                                else
                                                                                  {
                                                                                    db.collection("myChats").doc(seller).update({
                                                                                      "myChats": FieldValue.arrayUnion([docID])
                                                                                    })
                                                                                  }
                                                                              }),
                                                                  db
                                                                      .collection(
                                                                          "myChats")
                                                                      .doc(user)
                                                                      .get()
                                                                      .then(
                                                                          (userSnapshot) =>
                                                                              {
                                                                                if (!userSnapshot.exists)
                                                                                  {
                                                                                    db.collection("myChats").doc(user).set({
                                                                                      "myChats": [docID]
                                                                                    })
                                                                                  }
                                                                                else
                                                                                  {
                                                                                    db.collection("myChats").doc(user).update({
                                                                                      "myChats": FieldValue.arrayUnion([docID])
                                                                                    })
                                                                                  }
                                                                              }),
                                                                }
                                                            });
                                                    Navigator.of(context).push(
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ContactSellerScreen(
                                                                  chatID: docID,
                                                                  theOtherUserId:
                                                                      user,
                                                                  theOtherUserName:
                                                                      userDoc2[
                                                                          'username'],
                                                                )));
                                                  },
                                                  // style: ElevatedButton.styleFrom(
                                                  //   primary: Color.fromRGBO(
                                                  //       100, 170, 255, 1),
                                                  // ),
                                                  child: Text("Chat"),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                    doc['sellerReceivedPayment'] == false
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text('I have received payment'),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      offersReceived
                                                          .doc(doc.id)
                                                          .set(
                                                              {
                                                            'sellerReceivedPayment':
                                                                true
                                                          },
                                                              SetOptions(
                                                                  merge: true));
                                                    },
                                                    child: Text('Confirm'))
                                              ],
                                            ),
                                          )
                                        : Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                Text('Transaction completed!'),
                                          )
                                  ],
                                ),
                              ),
                            );
                          });
                    }).toList(),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
