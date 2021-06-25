import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orbital2796_nusell/models/user.dart';
import 'package:orbital2796_nusell/screens/home.dart';
import 'package:orbital2796_nusell/screens/verify.dart';
import 'package:orbital2796_nusell/services/db.dart';

class AuthService with ChangeNotifier {
  NUSellUser _currentUser;
  NUSellUser get currentUser => _currentUser;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore db = FirebaseFirestore.instance;

  signup(String email, String password, BuildContext context) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User firebaseUser = cred.user;
      NUSellUser user =
          NUSellUser(uid: firebaseUser.uid, email: email, password: password);
      print(user.uid);
      await UserDatabaseService(uid: user.uid).updateUserData(user);
      print(user.uid);
      //Success
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => VerifyScreen()));
    } on FirebaseAuthException catch (error) {
      print(error.message);
      Fluttertoast.showToast(msg: error.message, gravity: ToastGravity.TOP);
    }
  }

  signin(String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      //Success
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomeScreen()));
    } on FirebaseAuthException catch (error) {
      print(error.message);
      Fluttertoast.showToast(msg: error.message, gravity: ToastGravity.TOP);
    }
  }

  signout() async {
    await _auth.signOut();
  }

  Future _populateCurrentUser(User user) async {
    if (user != null) {
      _currentUser = await UserDatabaseService(uid: user.uid).getUser();
    }
  }

  Future getCurrentUser() async {
    return _auth.currentUser;
  }

  // GET UID
  String getCurrentUID() {
    return _auth.currentUser.uid;
  }

  getProfileImage() {
    if (_auth.currentUser.photoURL != null) {
      return Image.network(
        _auth.currentUser.photoURL,
        height: 100,
        width: 100,
      );
    } else {
      return Icon(Icons.account_circle, size: 100);
    }
  }

  Future<bool> isUserLogged() async {
    var user = _auth.currentUser;
    await _populateCurrentUser(user);
    return user != null;
  }

  Future deleteUser(String email, String password) async {
    try {
      User user = _auth.currentUser;
      AuthCredential credentials =
          EmailAuthProvider.credential(email: email, password: password);
      print(user);
      UserCredential result =
          await user.reauthenticateWithCredential(credentials);
      await UserDatabaseService(uid: result.user.uid)
          .deleteUser(); // called from database class
      await result.user.delete();
      return true;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool> validatePassword(String password) async {
    var firebaseUser = await _auth.currentUser;

    var authCredentials = EmailAuthProvider.credential(
        email: firebaseUser.email, password: password);
    try {
      var authResult =
          await firebaseUser.reauthenticateWithCredential(authCredentials);
      return authResult.user != null;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> updatePassword(String password) async {
    var firebaseUser = await _auth.currentUser;
    firebaseUser.updatePassword(password);
  }
}
