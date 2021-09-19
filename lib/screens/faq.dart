import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  var db = FirebaseFirestore.instance;

  List<Container> getListOfQuestionCategories(Map<String, dynamic> faq) {
    List<Container> result = new List();
    int len = faq.length;
    var keys = faq.keys;
    var values = faq.values;
    for (int i = 0; i < len; i++) {
      String title = keys.elementAt(i);
      var value = values.elementAt(i);
      ExpansionTile category = new ExpansionTile(
        title: Text(title),
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.5),
        children: getListOfQuestions(value),
      );
      Container container = new Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color.fromRGBO(242, 195, 71, 1), width: 1.5)
          ),
        ),
        child: category,
      );
      result.add(container);
    }
    return result;
  }

  List<Container> getListOfQuestions(List<dynamic> questions) {
    List<Container> result = new List();
    int len = questions.length;
    for (int i = 0; i < len; i++) {
      ExpansionTile question = new ExpansionTile(
        title: Text(questions[i]["Q"]),
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.5),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            child: Text(questions[i]["A"]),
          )
        ],
      );
      Container container = new Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(color: Color.fromRGBO(242, 195, 71, 1), width: 0.5)
          ),
        ),
        child: question,
      );
      result.add(container);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Frequently Asked Questions"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/images/background.png"),
              fit: BoxFit.fill,
              alignment: Alignment.bottomRight),
        ),
        child: StreamBuilder(
          stream: db.collection("about").doc("FAQ").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            var faq = snapshot.data.data();
            return Padding(
              padding: const EdgeInsets.all(30),
              child: ListView(
                children: getListOfQuestionCategories(faq),
              ),
            );
          },
        )
      )
    );
  }
}