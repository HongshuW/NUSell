import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class backgroundTimer {
  // starting time of the current action.
  DateTime startingTime;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // constructor of the backgroundTimer class.
  backgroundTimer(DateTime startingTime) {
    this.startingTime = startingTime;
  }

  // calculate the duration of the current action in minutes.
  int getDuration(DateTime endingTime) {
    return endingTime.difference(startingTime).inSeconds;
  }

  getIncrementPreference(var factor) {
    return factor * getDuration(DateTime.now());
  }

  void updatePreference(String category, String location, String sellerId, var factor) async {
    var increment = factor == 0 ? 5 : getIncrementPreference(factor);
    num originalCat = 0;
    num originalLoc = 0;
    num originalSeller = 0;
    String user = auth.currentUser.uid;

    // retrieve original extend of preference.
    await db.collection("personalPreference").doc(user).get()
        .then((DocumentSnapshot document) {
          if (document.exists) {
            if (category != null && document["Categories"][category] != null) {
              originalCat = document["Categories"][category];
            }
            if (location != null && document["Locations"][location] != null) {
              originalLoc = document["Locations"][location];
            }
            if (sellerId != null && document["Sellers"][sellerId] != null) {
              originalSeller = document["Sellers"][sellerId];
            }
          } else {
            db.collection("personalPreference").doc(user).set({
              "Categories": {}, "Locations": {}, "Sellers": {}});
          }
        });

    Map updatedVals = {};
    if (category != null) {
      updatedVals["Categories.${category}"] = originalCat + increment;
    }
    if (location != null) {
      updatedVals["Locations.${location}"] = originalLoc + increment;
    }
    if (sellerId != null) {
      updatedVals["Sellers.${sellerId}"] = originalSeller + increment;
    }

    // update preferences
    db.collection("personalPreference").doc(user)
        .update(Map<String, Object>.from(updatedVals));
  }

  @override
  String toString() {
    return "Timer starting from ${startingTime}.";
  }
}