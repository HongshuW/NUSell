import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContactSellerScreen extends StatefulWidget {
  final String seller;
  ContactSellerScreen({Key key, this.seller}) : super(key: key);

  @override
  State<ContactSellerScreen> createState() => _ContactSellerScreenState();
}

class _ContactSellerScreenState extends State<ContactSellerScreen> {

  String contact;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: BackButton(),
      ),
      body: Center(
        child: FutureBuilder<DocumentSnapshot>(
          future: db.collection("users").doc(widget.seller).get(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot){
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            Map<String, dynamic> seller = snapshot.data.data();
            return Text("Contact the seller: ${seller["phoneNumber"]}");
          },
        ),
      ),
    );
  }
}