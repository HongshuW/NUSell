import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/models/filterItem.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class filtersProvider with ChangeNotifier {
  // originally no filter is selected.
  List<Filter> _selectedFilters = [];
  CollectionReference _posts = FirebaseFirestore.instance.collection("posts");
  Query<Map<String, dynamic>> _query;

  Time time;
  Category category;
  Location location;
  Price price;

  // values
  Timestamp _timeRequested = Timestamp.fromDate(DateTime(2021));
  List<String> _categorySelected = [
    'Textbooks',
    'Notes',
    'Food',
    'Appliances',
    'Electronics',
    'Cosmetics',
    'Toys',
    'Others',
  ];
  List<String> _locationSelected = [
    "UTown",
    "PGP",
    "Kent Ridge MRT",
    'Central Library',
    'YIH',
    'Outside NUS',
    'Others',
  ];
  List<double> _range = [double.negativeInfinity, double.infinity];

  List<Filter> get selectedFilters => _selectedFilters;
  Timestamp get timeRequested => _timeRequested;
  List<String> get categorySelected => _categorySelected;
  List<String> get locationSelected => _locationSelected;
  List<double> get range => _range;

  set timeRequested(Timestamp newTime) {
    _timeRequested = newTime;
    notifyListeners();
  }

  set categorySelected(List<String> selectedCat) {
    _categorySelected = selectedCat;
    notifyListeners();
  }

  set locationSelected(List<String> selectedLoc) {
    _locationSelected = selectedLoc;
    notifyListeners();
  }

  set range(List<double> newRange) {
    _range = newRange;
    notifyListeners();
  }

  update(Filter filterItem) {
    if (filterItem is Time) {
      remove(time);
      time = filterItem;
    } else if (filterItem is Category) {
      remove(category);
      category = filterItem;
    } else if (filterItem is Location) {
      remove(location);
      location = filterItem;
    } else if (filterItem is Price) {
      remove(price);
      price = filterItem;
    }
    _selectedFilters.add(filterItem);
    // updateQuery();
    notifyListeners();
  }

  remove(Filter filterItem) {
    if (filterItem is Time) {
      _timeRequested = Timestamp.fromDate(DateTime(2021));
    } else if (filterItem is Category) {
      _categorySelected = [
        'Textbooks',
        'Notes',
        'Food',
        'Appliances',
        'Electronics',
        'Cosmetics',
        'Toys',
        'Others',
      ];
    } else if (filterItem is Location) {
      _locationSelected = [
        "UTown",
        "PGP",
        "Kent Ridge MRT",
        'Central Library',
        'YIH',
        'Outside NUS',
        'Others',
      ];
    } else if (filterItem is Price) {
      _range = [double.negativeInfinity, double.infinity];
    }
    _selectedFilters.remove(filterItem);
    if (_selectedFilters.length != 0) {
      updateQuery();
    } else {
      clear();
    }
    notifyListeners();
  }

  clear() {
    _selectedFilters = [];
    _query = null;
    _timeRequested = Timestamp.fromDate(DateTime(2021));
    _categorySelected = [
      'Textbooks',
      'Notes',
      'Food',
      'Appliances',
      'Electronics',
      'Cosmetics',
      'Toys',
      'Others',
    ];
    _locationSelected = [
      "UTown",
      "PGP",
      "Kent Ridge MRT",
      'Central Library',
      'YIH',
      'Outside NUS',
      'Others',
    ];
    _range = [double.negativeInfinity, double.infinity];
  }

  List<InkWell> toWidgets() {
    List<InkWell> list = [];
    for (Filter filter in _selectedFilters) {
      list.add(filter.toButton());
    }
    return list;
  }

  updateQuery() {
    var i;
    for (i = 0; i < _selectedFilters.length; i++) {
      if (i == 0) {
        _query = _selectedFilters[i].updateQuery(_posts);
      } else {
        _query = _selectedFilters[i].updateQuery(_query);
      }
    }
    notifyListeners();
  }

  Query<Map<String, dynamic>> getQuery() {
    if (_query == null) {
      return FirebaseFirestore.instance
          .collection("posts")
          .orderBy("time", descending: true);
    } else {
      return _query.orderBy("time", descending: true);
    }
  }
}