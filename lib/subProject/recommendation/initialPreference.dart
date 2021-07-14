import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class initialPreference {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<dynamic> categories;
  List<dynamic> locations;
  Map preference = {};
  num initialValue = 5;

  initialPreference(List<dynamic> categories, List<dynamic> locations) {
    this.categories = categories;
    this.locations = locations;
  }

  getPreference() {
    Map<String, num> cat = {};
    Map<String, num> loc = {};
    for (var i = 0; i < this.categories.length; i++) {
      cat[this.categories[i].toString()] = this.initialValue;
    }
    for (var j = 0; j < this.locations.length; j++) {
      loc[this.locations[j].toString()] = this.initialValue;
    }
    this.preference["Categories"] = cat;
    this.preference["Locations"] = loc;
    this.preference["Sellers"] = {};
  }

  setPreference() {
    getPreference();
    db.collection("personalPreference").doc(auth.currentUser.uid)
        .set(Map<String, dynamic>.from(this.preference));
  }
}