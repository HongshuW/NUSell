import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orbital2796_nusell/subProject/custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orbital2796_nusell/providers/postsProvider.dart';
import 'package:orbital2796_nusell/providers/filtersProvider.dart';
import 'package:orbital2796_nusell/models/filterItem.dart';

class Filter extends StatefulWidget {
  final int type;
  Filter({Key key, this.type}) : super(key: key);

  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  var newSnapshot;
  var index = 0;

  @override
  Widget build(BuildContext context) {
    final posts = Provider.of<postsProvider>(context);
    final selected = Provider.of<filtersProvider>(context);
    Time time;
    Category category;
    Location location;
    Price price;
    SellerScore sellerScore;

    var timeRequested;
    // 5: view all
    if (widget.type == 0 || widget.type == 5) {
      posts.clear();
      selected.clear();
      return Container(
        margin: EdgeInsets.all(10),
      );
    }
    return Container(
      height: 40,
      child: ListView(
        children: [
          // 1: filter by time posted
          widget.type == 1
              ? Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: CustomRadioButton(
                    elevation: 0,
                    enableShape: true,
                    autoWidth: true,
                    height: 25,
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
                      timeRequested =
                          DateTime.now().add(Duration(days: -1 * value)),
                      time =
                          Time(posts: posts, selected: selected, value: value),
                      selected.update(time),
                      selected.timeRequested =
                          Timestamp.fromDate(timeRequested),
                      // posts.snapshot = selected.getQuery(),
                    },
                  ),
                )
              : Container(),
          // 2: filter by category
          widget.type == 2
              ? Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: new CustomCheckBoxGroup(
                    key: Key("category"),
                    elevation: 0,
                    enableShape: true,
                    // enableButtonWrap: true,
                    autoWidth: true,
                    height: 25,
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
                    checkBoxButtonValues: (values) => {
                      category = Category(
                          posts: posts, selected: selected, value: values),
                      selected.update(category),
                      selected.categorySelected = values
                    },
                  ),
                )
              : Container(),
          // 3: filter by location
          widget.type == 3
              ? Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: new CustomCheckBoxGroup(
                    key: Key("location"),
                    elevation: 0,
                    enableShape: true,
                    // enableButtonWrap: true,
                    autoWidth: true,
                    height: 25,
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
                    checkBoxButtonValues: (values) => {
                      location = Location(
                          posts: posts, selected: selected, value: values),
                      selected.update(location),
                      selected.locationSelected = values,
                    },
                  ),
                )
              : Container(),
          // 4: filter by price
          widget.type == 4
              ? Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: CustomRadioButton(
                    elevation: 0,
                    enableShape: true,
                    autoWidth: true,
                    height: 25,
                    buttonLables: ['< 10', '10 - 50', '50 - 100', '≥ 100'],
                    buttonValues: [
                      [0.0, 10.0],
                      [10.0, 50.0],
                      [50.0, 100.0],
                      [100.0, double.infinity]
                    ],
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
                      price =
                          Price(posts: posts, selected: selected, value: value),
                      selected.update(price),
                      selected.range = value,
                    },
                  ),
                )
              : Container(),
          //11: filter by sellerScore
          widget.type == 11
              ? Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: CustomRadioButton(
                    elevation: 0,
                    enableShape: true,
                    autoWidth: true,
                    height: 25,
                    buttonLables: ['> 4.5', '> 4.0', '> 3.5'],
                    buttonValues: [
                      [4.5, 5.0],
                      [4.0, 5.0],
                      [3.5, 5.0],
                    ],
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
                      sellerScore = SellerScore(
                          posts: posts, selected: selected, value: value),
                      selected.update(sellerScore),
                      selected.range = value,
                    },
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
