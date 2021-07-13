import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/screens/productinfo.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:orbital2796_nusell/services/auth.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key key}) : super(key: key);

  @override
  _TransactionHistoryScreenState createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  CollectionReference offersMade = FirebaseFirestore.instance
      .collection('users')
      .doc(AuthService().getCurrentUID())
      .collection('offersMade');

  CollectionReference offersReceived = FirebaseFirestore.instance
      .collection('users')
      .doc(AuthService().getCurrentUID())
      .collection('offersReceived');
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  TabController _tabController;
  List<Tab> tabs = <Tab>[
    Tab(
      text: 'As a buyer',
    ),
    Tab(
      text: 'As a seller',
    ),
  ];

  // @override
  // void initState() {
  //   super.initState();
  //   _tabController = DefaultTabController.of(context);
  //   asBuyer = true;
  // }

  // @override
  // void dispose() {
  //   _tabController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context);
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            // Your code goes here.
            // To get index of current tab use tabController.index
          }
        });
        return Scaffold(
          appBar: AppBar(
            title: Text('transaction history'),
            leading: BackButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => ProfileScreen()));
              },
            ),
            bottom: TabBar(
              tabs: tabs,
            ),
          ),
          body: TabBarView(
            children: tabs.map((Tab tab) {
              if (tab.text == 'As a buyer') {
                return Container(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: offersMade.snapshots(),
                      builder: (context, querySnapshot) {
                        if (querySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Not yet');
                        }
                        return ListView(
                            children: querySnapshot.data.docs.map((doc) {
                          Timestamp time = doc['time'];
                          DateTime timeAsString = time.toDate();
                          List pricesOffered = doc['price'];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.lightGreen,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: StreamBuilder<DocumentSnapshot>(
                                  stream: posts.doc(doc.id).snapshots(),
                                  builder: (context2, snapshot2) {
                                    if (!snapshot2.hasData) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                    Map<String, dynamic> post =
                                        snapshot2.data.data();
                                    if (doc['status'] != 'Accepted' ||
                                        doc['buyerReceivedProduct'] == false) {
                                      return Container();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
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
                                                                    product: doc
                                                                        .id)));
                                                  },
                                                  child: Text('View'))
                                            ],
                                          ),
                                          Text(
                                              'Price accepted: ${doc['priceAccepted']}'),
                                          timeAsString != null
                                              ? Text(timeAsString.toString())
                                              : Container()
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                          );
                        }).toList());
                      }),
                );
              } else {
                return Container(
                  child: ListView(shrinkWrap: true, children: [
                    StreamBuilder<QuerySnapshot>(
                        stream: offersReceived.snapshots(),
                        builder: (context, querySnapshot) {
                          if (querySnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text('Not yet');
                          }
                          return ListView(
                            shrinkWrap: true,
                            children: querySnapshot.data.docs.map((doc) {
                              if (doc['status'] != 'Accepted' ||
                                  doc['sellerReceivedPayment'] == false) {
                                return Container();
                              }
                              Timestamp time = doc['time'];
                              DateTime timeAsString = time.toDate();
                              return StreamBuilder<DocumentSnapshot>(
                                  stream: posts.doc(doc.id).snapshots(),
                                  builder: (context2, snapshot2) {
                                    if (!snapshot2.hasData) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                    Map<String, dynamic> post =
                                        snapshot2.data.data();
                                    Map<String, dynamic> offers = doc.data();
                                    Map userAccepted = offers['userAccepted'];

                                    if (userAccepted == null)
                                      return Container();
                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.lightGreen,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                'Product: ${post['productName']}',
                                                style: TextStyle(fontSize: 22),
                                              ),
                                            ),
                                            StreamBuilder<DocumentSnapshot>(
                                                stream: users
                                                    .doc(userAccepted[
                                                        'offerFromUser'])
                                                    .snapshots(),
                                                builder: (context, snapshot4) {
                                                  if (!snapshot4.hasData) {
                                                    return Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  }
                                                  Map<String, dynamic>
                                                      userDoc2 =
                                                      snapshot4.data.data();
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      'User ${userDoc2['username']} with offer price of ${userAccepted['priceOffered']}',
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                  );
                                                }),
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProductInfoScreen(
                                                                  product:
                                                                      doc.id)));
                                                },
                                                child: Text('View')),
                                            timeAsString != null
                                                ? Text(timeAsString.toString())
                                                : Container()
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }).toList(),
                          );
                        }),
                  ]),
                );
              }
            }).toList(),
          ),
        );
      }),
    );
  }
}
