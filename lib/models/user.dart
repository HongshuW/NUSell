class NUSellUser {
  final String uid;
  final String username;
  final String email;
  final String password;

  NUSellUser({this.uid, this.username, this.email, this.password});

  Map<String, dynamic> toMap() {
    return {'username': username, 'email': email, 'password': password};
  }
}
