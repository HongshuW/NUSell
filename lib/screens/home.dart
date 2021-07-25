import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/screens/forum.dart';
import 'package:orbital2796_nusell/screens/myChats.dart';
import 'package:orbital2796_nusell/screens/shoppingCart.dart';
import 'package:orbital2796_nusell/services/auth.dart';
import 'package:orbital2796_nusell/subProject/custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:orbital2796_nusell/providers/filtersProvider.dart';
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
    final selected = Provider.of<filtersProvider>(context);
    getToken();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: WillPopScope(
        onWillPop: () async {
          if (Navigator.of(context).userGestureInProgress)
            return false;
          else
            return true;
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,

          // search bar
          appBar: AppBar(
            actions: [
              IconButton(
                  color: Colors.black,
                  icon: Icon(
                    Icons.favorite_border_outlined,
                  ),
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
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LoginScreen()));
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
                  contentPadding:
                      EdgeInsets.only(left: 10, top: 5, bottom: 5),
                  fillColor: Color.fromRGBO(249, 248, 253, 1),
                  filled: true,
                ),
              ),
            ),
          ),

          body: Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(195, 215, 223, 0.2),
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

          // Navigation bar
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            selectedItemColor: Color.fromRGBO(242, 195, 71, 1),
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.house), label: "Home"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.art_track), label: "Forum"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_rounded), label: "Messages"),
              BottomNavigationBarItem(icon: Icon(Icons.add), label: "Sell"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: "Profile"),
            ],
            onTap: (index) {
              if (auth.currentUser == null) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
              } else {
                if (index == 1) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ForumScreen()));
                } else if (index == 2) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MyChatsScreen()));
                } else if (index == 3) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PostScreen()));
                } else if (index == 4) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileScreen()));
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
