import 'package:cloud_firestore/cloud_firestore.dart';

class SearchService {
  Future<QuerySnapshot> searchByName(String searchField) {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('searchKey',
            isEqualTo: searchField.substring(0, 1).toLowerCase())
        .get();
  }

  Future<QuerySnapshot> fullTextSearch(String searchField) {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('status', isEqualTo: 'selling')
        //.where('nameForSearch', isGreaterThanOrEqualTo: searchField)
        .get();
  }
}
