import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orbital2796_nusell/subProject/custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:orbital2796_nusell/screens/home.dart';
import 'package:orbital2796_nusell/subProject/recommendation/initialPreference.dart';

class InterestsScreen extends StatefulWidget {
  InterestsScreen({Key key}) : super(key: key);

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  List<dynamic> categories = [];
  List<dynamic> locations = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(top: 30, left: 30, right: 30),
          decoration: BoxDecoration(
            color: Color.fromRGBO(249, 241, 219, 1),
            image: DecorationImage(
              image: AssetImage("assets/images/waveTop.png"),
              fit: BoxFit.fitWidth,
              alignment: Alignment.topLeft
            ),
          ),
          child: ListView(
            children: [
              // skip button
              Container(
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(bottom: 50),
                child: InkWell(
                    onTap: () {
                      db.collection("personalPreference").doc(auth.currentUser.uid).set({
                        "Categories": {}, "Locations": {}, "Sellers": {}});
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => HomeScreen()));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text("Skip", style: TextStyle(color: Colors.brown)),
                        Icon(
                            Icons.arrow_forward,
                            color: Colors.brown,
                          size: 16,
                        ),
                      ],
                    )),
              ),

              // title
              Container(
                alignment: Alignment.topLeft,
                child: Text(
                    "Select Your Interests",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown
                  ),
                ),
              ),

              // Subtitle: categories
              Container(
                margin: EdgeInsets.only(top: 50, bottom: 10, left: 10),
                  child: Text(
                      "Which categories of products are you looking for?",
                    style: TextStyle(
                      color: Colors.brown,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ),

              // categories
              CustomCheckBoxGroup(
                checkBoxButtonValues: (categories) {
                  this.categories = categories;
                },
                buttonLables: [
                  'Textbooks',
                  'Notes',
                  'Food',
                  'Appliances',
                  'Electronics',
                  'Cosmetics',
                  'Toys',
                  'Others',
                ],
                buttonValuesList: [
                  'Textbooks',
                  'Notes',
                  'Food',
                  'Appliances',
                  'Electronics',
                  'Cosmetics',
                  'Toys',
                  'Others',
                ],
                autoWidth: true,
                enableButtonWrap: true,
                enableShape: true,
                unSelectedColor: Colors.white30,
                selectedColor: Color.fromRGBO(242, 195, 71, 1),
                buttonTextStyle: ButtonTextStyle(unSelectedColor: Colors.brown),
              ),

              // Subtitle: locations
              Container(
                margin: EdgeInsets.only(top: 50, bottom: 10, left: 10),
                child: Text(
                  "Which locations would you prefer for the tradings to take place?",
                  style: TextStyle(
                    color: Colors.brown,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // locations
              CustomCheckBoxGroup(
                checkBoxButtonValues: (locations) {
                  this.locations = locations;
                },
                buttonLables: [
                  'UTown',
                  'PGP',
                  'Kent Ridge MRT',
                  'Central Library',
                  'YIH',
                  'Outside NUS',
                  'Others',
                ],
                buttonValuesList: [
                  "UTown",
                  "PGP",
                  "Kent Ridge MRT",
                  'Central Library',
                  'YIH',
                  'Outside NUS',
                  'Others',
                ],
                autoWidth: true,
                enableButtonWrap: true,
                enableShape: true,
                unSelectedColor: Colors.white30,
                selectedColor: Color.fromRGBO(242, 195, 71, 1),
                buttonTextStyle: ButtonTextStyle(unSelectedColor: Colors.brown),
              ),

              // next
              Container(
                margin: EdgeInsets.only(top: 30, bottom: 50, left: 50, right: 50),
                  child: ElevatedButton(
                    onPressed: () {
                      initialPreference setter
                        = initialPreference(this.categories, this.locations);
                      setter.setPreference();
                      Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => HomeScreen()));
                    },
                    child: Text("Finish", style: TextStyle(color: Colors.brown)),
                  ),
              ),
            ],
          ),
      ),
    );
  }
}