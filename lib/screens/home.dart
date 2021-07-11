import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/screens/myChats.dart';
import 'package:orbital2796_nusell/screens/shoppingCart.dart';
import 'package:orbital2796_nusell/services/auth.dart';
import 'package:orbital2796_nusell/subProject/custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:orbital2796_nusell/providers/filtersProvider.dart';
import 'package:orbital2796_nusell/providers/postsProvider.dart';
import 'package:orbital2796_nusell/providers/userInfoProvider.dart';
import 'package:orbital2796_nusell/screens/post.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:orbital2796_nusell/screens/filter.dart';
import 'package:orbital2796_nusell/screens/allPosts.dart';
import 'package:orbital2796_nusell/screens/searchbar.dart';
import 'package:orbital2796_nusell/screens/selectedFilters.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // firebase fields
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  // filters fields
  int type = 5;

  // back to top fields
  ScrollController scrollController = ScrollController();
  getToken() async {
    String token = await FirebaseMessaging.instance.getToken();
    FirebaseFirestore.instance
        .collection('users')
        .doc(AuthService().getCurrentUID())
        .set({'androidNotificationToken': token}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    // Providers
    final userinfoProvider =
        Provider.of<userInfoProvider>(context, listen: false);
    final posts = Provider.of<postsProvider>(context);
    final selected = Provider.of<filtersProvider>(context);
    getToken();

    return ChangeNotifierProvider(
      create: (context) => postsProvider(),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,

          // search bar
          appBar: AppBar(
            actions: [
              IconButton(
                  color: Colors.black,
                  icon: Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MyShoppingCartsScreen(
                              userId: AuthService().getCurrentUID(),
                            )));
                  }),
            ],
            automaticallyImplyLeading: false,
            backgroundColor: Color.fromRGBO(242, 195, 71, 1),
            elevation: 0,
            title: Container(
              margin: EdgeInsets.only(left: 40, right: 40),
              child: TextField(
                onTap: () {
                  if (auth.currentUser == null) {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  } else {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => SearchBar()));
                  }
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

          body: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(249, 248, 253, 1),
            ),
            child: ListView(
              // controller: scrollController,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 30, right: 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromRGBO(242, 195, 71, 1),
                        Color.fromRGBO(252, 228, 70, 1),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),

                  // filters
                  child: Column(
                    children: [
                      CustomRadioButton(
                        defaultSelected: 5,
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
                          'SellerScore',
                          'View All'
                        ],
                        buttonValues: [1, 2, 3, 4, 11, 5],
                        buttonTextStyle: ButtonTextStyle(
                          selectedColor: Color.fromRGBO(190, 140, 90, 1),
                          unSelectedColor: Colors.white,
                          textStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        radioButtonValue: (value) => {
                          setState(() {
                            this.type = value;
                          })
                        },
                        unSelectedColor: Colors.transparent,
                        selectedColor: Color.fromRGBO(250, 190, 90, 0.5),
                        unSelectedBorderColor: Colors.white,
                        selectedBorderColor: Color.fromRGBO(190, 140, 90, 1),
                      ),
                      Filter(type: this.type),
                      selectedFilters(),
                    ],
                  ),
                ),

                // display posts
                allPosts(hasPagination: this.type == 5),
              ],
            ),
          ),

          // a collection of three floating action buttons, on pressed will
          // turn to another page
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: Container(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FloatingActionButton(
                  heroTag: "home",
                  child: Icon(Icons.house, color: Colors.white),
                  backgroundColor: Color.fromRGBO(247, 215, 140, 1),
                  onPressed: () {},
                ),
                FloatingActionButton(
                  heroTag: "chat",
                  onPressed: () {
                    if (auth.currentUser == null) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => LoginScreen()));
                    } else {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => MyChatsScreen()));
                    }
                  },
                  child: Icon(Icons.chat_bubble_rounded, color: Colors.white),
                  backgroundColor: Color.fromRGBO(242, 195, 71, 1),
                ),
                FloatingActionButton(
                  heroTag: "post",
                  onPressed: () {
                    if (auth.currentUser == null) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => LoginScreen()));
                    } else {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => PostScreen()));
                    }
                  },
                  child: Icon(Icons.add, color: Colors.white),
                  backgroundColor: Color.fromRGBO(242, 195, 71, 1),
                ),
                FloatingActionButton(
                  heroTag: "profile",
                  onPressed: () {
                    if (auth.currentUser == null) {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => LoginScreen()));
                    } else {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => ProfileScreen()));
                    }
                  },
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                  backgroundColor: Color.fromRGBO(242, 195, 71, 1),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
