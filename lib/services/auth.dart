import 'package:firebase_auth/firebase_auth.dart';
import 'package:orbital2796_nusell/services/db.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future deleteUser(String email, String password) async {
    try {
      User user = _auth.currentUser;
      AuthCredential credentials =
          EmailAuthProvider.credential(email: email, password: password);
      print(user);
      UserCredential result =
          await user.reauthenticateWithCredential(credentials);
      await DatabaseService(uid: result.user.uid)
          .deleteuser(); // called from database class
      await result.user.delete();
      return true;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
