import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:orbital2796_nusell/providers/postsProvider.dart';

class Filter extends StatefulWidget {
  final int value;
  Filter({Key key, this.value}) : super(key : key);

  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  var newSnapshot;

  @override
  Widget build(BuildContext context) {
    final posts = Provider.of<postsProvider>(context);

    // 1: filter by time posted
    if (widget.value == 1) {
      return Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: CustomRadioButton(
          elevation: 0,
          enableShape: true,
          height: 25,
          width: 110,
          buttonLables: [
            'past 24 hours',
            'past 7 days',
            'past 30 days',
          ],
          buttonValues: [1, 7, 30],
          buttonTextStyle: ButtonTextStyle(
            selectedColor: Colors.white,
            unSelectedColor: Colors.black,
            textStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
          ),
          unSelectedColor: Colors.transparent,
          selectedColor: Color.fromRGBO(242, 195, 71, 1),
          unSelectedBorderColor: Colors.black45,
          selectedBorderColor: Color.fromRGBO(242, 195, 71, 1),
          radioButtonValue: (value) => {
            newSnapshot = FirebaseFirestore.instance.collection("posts").orderBy("time", descending: true).limit(1).snapshots(),
            posts.snapshot = newSnapshot,
          },
        ),
      );
    } else if (widget.value == 2) {
      return Container(
        margin: EdgeInsets.all(10),
      );
    } else if (widget.value == 3) {
      return Container(
        margin: EdgeInsets.all(10),
      );
    } else if (widget.value == 4) {
      return Container(
        margin: EdgeInsets.all(10),
      );
    } else {
      posts.clear();
      return Container(
        margin: EdgeInsets.all(10),
      );
    }
  }
}