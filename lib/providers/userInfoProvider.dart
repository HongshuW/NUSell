import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/models/user.dart';
import 'package:orbital2796_nusell/services/db.dart';

class userInfoProvider with ChangeNotifier {
  final userDatabaseService = UserDatabaseService();

  String _username = '';
  //String _email = '';
  String _uid;

  //getters
  String get username => _username;
  //String get email => _email;
  Future get user => userDatabaseService.getUser();

  //setter
  set changeUserName(String username) {
    _username = username;
    notifyListeners();
  }

  // set changeEmail(String email) {
  //   _email = email;
  //   notifyListeners();
  // }

  //function
  loadUser(NUSellUser user) {
    _username = user.username;
    _uid = user.uid;
  }
}
