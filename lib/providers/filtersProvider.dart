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

  // range of price
  List<double> _range = [double.negativeInfinity, double.infinity];

  List<Filter> get selectedFilters => _selectedFilters;
  List<double> get range => _range;

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
    updateQuery();
    notifyListeners();
  }

  remove(Filter filterItem) {
    if (filterItem is Price) {
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

  Stream<QuerySnapshot> getSnapshot() {
    if (_query == null) {
      return FirebaseFirestore.instance
          .collection("posts")
          .orderBy("time", descending: true)
          .limit(10)
          .snapshots();
    } else {
      return _query.orderBy("time", descending: true).snapshots();
    }
  }
}