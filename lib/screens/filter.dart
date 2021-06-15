import 'package:orbital2796_nusell/subProject/custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:orbital2796_nusell/providers/postsProvider.dart';
import 'package:orbital2796_nusell/providers/filtersProvider.dart';
import 'package:orbital2796_nusell/models/filterItem.dart';

class Filter extends StatefulWidget {
  final int type;
  Filter({Key key, this.type}) : super(key : key);

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
    var filter;

    // 1: filter by time posted
    if (widget.type == 1) {
      var now = DateTime.now();
      var timeRequested;
      return Container(
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
            timeRequested = now.add(Duration(days: -1 * value)),
            filter = Time(posts: posts, selected: selected, value: value),
            selected.update(filter),
            posts.snapshot = selected.getQuery(),
          },
        ),
      );
    }
    // 2: filter by category
    else if (widget.type == 2) {
      return Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: CustomRadioButton(
          elevation: 0,
          enableShape: true,
          enableButtonWrap: true,
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
          buttonValues: [
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
          radioButtonValue: (value) => {
            filter = Category(posts: posts, selected: selected, value: value),
            selected.update(filter),
            posts.snapshot = selected.getQuery(),
          },
        ),
      );
    }
    // 3: filter by location
    else if (widget.type == 3) {
      return Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: CustomRadioButton(
          elevation: 0,
          enableShape: true,
          enableButtonWrap: true,
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
          buttonValues: [
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
          radioButtonValue: (value) => {
            filter = Location(posts: posts, selected: selected, value: value),
            selected.update(filter),
            posts.snapshot = selected.getQuery(),
          },
        ),
      );
    }
    // 4: filter by price
    else if (widget.type == 4) {
      return Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: CustomRadioButton(
          elevation: 0,
          enableShape: true,
          autoWidth: true,
          height: 25,
          buttonLables: [
            '< 10',
            '10 - 50',
            '50 - 100',
            '≥ 100'
          ],
          buttonValues: [[0.0,10.0],[10.0,50.0],[50.0,100.0],[100.0,double.infinity]],
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
            filter = Price(posts: posts, selected: selected, value: value),
            selected.update(filter),
            selected.range = value,
            posts.snapshot = selected.getQuery(),
          },
        ),
      );
    } else {
      posts.clear();
      selected.clear();
      return Container(
        margin: EdgeInsets.all(10),
      );
    }
  }
}