import 'package:cloud_firestore/cloud_firestore.dart';

class postsSorter {
  // user id.
  String user;
  final db = FirebaseFirestore.instance;
  Future<DocumentSnapshot<Map<String, dynamic>>> preferenceFuture = null;
  DocumentSnapshot<Map<String, dynamic>> preference = null;

  // constructor of the class.
  postsSorter(String user) {
    this.user = user;
    this.preferenceFuture = db.collection("personalPreference").doc(this.user).get();
  }

  // calculate the user's preference level about a post.
  calculatePreferenceVal(DocumentSnapshot post) async {
    // get key information of the post.
    String category = post["category"];
    String location = post["location"];
    String seller = post["user"];
    // get the user's personal preference
    if (preference == null) {
      preference = await preferenceFuture;
    }
    var categoryScore = preference["Categories"][category] == null
        ? 0 : preference["Categories"][category];
    var locationScore = preference["Locations"][location] == null
        ? 0 : preference["Locations"][location];
    var sellerScore = preference["Sellers"][seller] == null
        ? 0 : preference["Sellers"][seller];
    return categoryScore + locationScore + sellerScore;
  }

  // return a sorted list of posts.
  sorted(List<DocumentSnapshot> posts) async {
    // mark each post with its preference value.
    List<List> list = [];
    int len = posts.length;
    for (var i = 0; i < len; i++) {
      // in a pair, the first item is the post itself, the second item is its
      // preference value.
      List pair = [posts[i]];
      pair.add(await calculatePreferenceVal(posts[i]));
      list.add(pair);
    }

    // sort the resultant list.
    List<List> sorted = mergeSort(list);

    // convert the sorted list back to original form.
    List<DocumentSnapshot> resultantList = [];
    for (var i = 0; i < len; i++) {
      resultantList.add(sorted[i][0]);
    }
    print(sorted);
    return resultantList;
  }

  // sort the marked list recursively.
  List<List> mergeSort(List<List> list) {
    int len = list.length;
    if (list.length <= 1) {
      return list;
    }
    int split = (len / 2).floor();
    List<List> left = mergeSort(list.sublist(0, split));
    List<List> right = mergeSort(list.sublist(split, len));
    return merge(left, right);
  }

  // merge two sorted list.
  List<List> merge(List<List> left, List<List> right) {
    List<List> merged = [];
    mergeRecursive(List<List> remainingLeft, List<List> remainingRight) {
      if (remainingLeft.isEmpty) {
        merged.addAll(remainingRight);
      } else if (remainingRight.isEmpty) {
        merged.addAll(remainingLeft);
      } else {
        if (remainingLeft[0][1] < remainingRight[0][1]) {
          merged.add(remainingRight[0]);
          mergeRecursive(remainingLeft, remainingRight.sublist(1));
        } else {
          merged.add(remainingLeft[0]);
          mergeRecursive(remainingLeft.sublist(1), remainingRight);
        }
      }
    }
    mergeRecursive(left, right);
    return merged;
  }
}