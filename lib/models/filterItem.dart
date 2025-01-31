import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Filter {
  // filtersProvider
  final selected;
  // type of filter
  int type;
  // value of filter
  var value;

  Filter({this.selected, this.type, this.value});

  InkWell toButton() {
    return InkWell(
      onTap: () {
        selected.remove(this);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10, right: 5),
        padding: EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
        decoration: BoxDecoration(
          border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.5)),
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Color.fromRGBO(0, 0, 0, 0.5),
        ),
        child: Row(
          children: [
            Text(
              this.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
            Icon(
              Icons.clear,
              size: 12,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  List<InkWell> listOfButtons() {
    return [this.toButton()];
  }

  @override
  toString() {
    return this.value;
  }
}

class Time extends Filter {
  var timeRequested;
  Time({selected, value})
      : super(selected: selected, type: 1, value: value);

  @override
  toString() {
    if (super.value == 1) {
      return 'past 24 hours';
    } else if (super.value == 7) {
      return 'past 7 days';
    } else if (super.value == 30) {
      return 'past 30 days';
    } else {
      return "";
    }
  }
}

class Category extends Filter {
  Category({selected, value})
      : super(selected: selected, type: 2, value: value);

  @override
  List<InkWell> listOfButtons() {
    List<InkWell> result = [];
    for (var val in value) {
      result.add(InkWell(
        onTap: () {
          var categories = selected.categorySelected;
          categories.remove(val);
          if (categories.isEmpty) {
            selected.categorySelected = [
              'Textbooks',
              'Notes',
              'Food',
              'Appliances',
              'Electronics',
              'Cosmetics',
              'Toys',
              'Others',
            ];
          } else {
            selected.categorySelected = categories;
          }
          print(selected.categorySelected);
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 10, right: 5),
          padding: EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.5)),
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Color.fromRGBO(0, 0, 0, 0.5),
          ),
          child: Row(
            children: [
              Text(
                val == "Others" ? "Category: others" : val,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              Icon(
                Icons.clear,
                size: 12,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ));
    }
    return result;
  }

  @override
  toString() {
    if (this.value == "Others") {
      return 'Category: others';
    } else {
      return this.value.toString();
    }
  }
}

class Location extends Filter {
  Location({selected, value})
      : super(selected: selected, type: 3, value: value);

  @override
  List<InkWell> listOfButtons() {
    List<InkWell> result = [];
    for (var val in value) {
      result.add(InkWell(
        onTap: () {
          var locations = selected.locationSelected;
          locations.remove(val);
          if (locations.isEmpty) {
            selected.locationSelected = [
              "UTown",
              "PGP",
              "Kent Ridge MRT",
              'Central Library',
              'YIH',
              'Outside NUS',
              'Others',
            ];
          } else {
            selected.locationSelected = locations;
          }
          print(selected.locationSelected);
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 10, right: 5),
          padding: EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2),
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.5)),
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Color.fromRGBO(0, 0, 0, 0.5),
          ),
          child: Row(
            children: [
              Text(
                val == "Others" ? "Location: others" : val,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              Icon(
                Icons.clear,
                size: 12,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ));
    }
    return result;
  }

  @override
  toString() {
    if (this.value == "Others") {
      return 'Location: others';
    } else {
      return this.value.toString();
    }
  }
}

class Price extends Filter {
  Price({selected, value})
      : super(selected: selected, type: 4, value: value);

  @override
  toString() {
    if (super.value[0] == 0) {
      return '< 10';
    } else if (super.value[0] == 10) {
      return '10 - 50';
    } else if (super.value[0] == 50) {
      return '50 - 100';
    } else if (super.value[0] == 100) {
      return '≥ 100';
    } else {
      return '';
    }
  }
}

class SellerScore extends Filter {
  SellerScore({selected, value})
      : super(selected: selected, type: 11, value: value);

  @override
  String toString() {
    if (super.value[0] == 4.5) {
      return '> 4.5';
    } else if (super.value[0] == 4.0) {
      return '> 4.0';
    } else if (super.value[0] == 3.5) {
      return '> 3.5';
    } else {
      return '';
    }
  }
}
