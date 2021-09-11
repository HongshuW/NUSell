import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  final db = FirebaseFirestore.instance;
  String currentVersion = "1.0";

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: db.collection("about").doc("NUSell").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          Map<String, dynamic> appData = snapshot.data.data();
          return Scaffold(
            appBar: AppBar(
              title: Text("About"),
            ),
            body: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/background.png"),
                    fit: BoxFit.fill,
                    alignment: Alignment.bottomRight),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(blurRadius: 20)],
                      image: DecorationImage(
                        image: AssetImage("assets/images/lionZoomedIn.png"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 10.0),
                    child: Text(
                      appData["appName"],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Text(
                    "Current Version: " + currentVersion,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300
                    ),
                  ),
                  Text(
                    "Latest Version: " + appData["version"],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300
                    ),
                  ),
                  Text(
                    "Latest Update: " + DateTime.fromMillisecondsSinceEpoch(
                        appData["dateOfLastUpdate"].millisecondsSinceEpoch)
                        .toString().substring(0, 10),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, bottom: 10.0),
                    child: Text(
                      "Developers",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Text(
                    appData["developers"],
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, bottom: 10.0),
                    child: Text(
                      "Contact Us",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                  Text(
                    appData["contacts"],
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}