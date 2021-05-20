import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:orbital2796_nusell/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostScreen extends StatefulWidget {
  PostScreen({Key key}) : super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //on pressed will return back to the home screen
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HomeScreen()));
          },
        ),
        title: Text('To post an item'),
        backgroundColor: Color.fromRGBO(252, 228, 70, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(children: <Widget>[
          TextField(
            decoration: InputDecoration(hintText: "Product Name"),
            onChanged: (value){},
          ),
          // ignore: deprecated_member_use
          RaisedButton(
            child: Text("SUBMIT"),
            color: Color.fromRGBO(252, 228, 70, 1),
            onPressed: (){
            },
          ),
        ],
      ),
      ),
    );
  }
}
