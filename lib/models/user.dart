class NUSellUser {
  final String uid;
  String username;
  String phoneNumber;
  String avatarUrl;
  String email;
  String password;
  String gender;

  NUSellUser({
    this.uid,
    this.username,
    this.avatarUrl,
    this.phoneNumber,
    this.email,
    this.password,
    this.gender,
  });

  factory NUSellUser.fromJson(Map<String, dynamic> json) {
    return NUSellUser(
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      password: json['password'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'email': email,
      'password': password,
      'gender': gender,
    };
  }
}
