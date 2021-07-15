class NUSellUser {
  final String uid;
  String username;
  String phoneNumber;
  String avatarUrl;
  String gender;

  NUSellUser({
    this.uid,
    this.username,
    this.avatarUrl,
    this.phoneNumber,
    this.gender,
  });

  factory NUSellUser.fromJson(Map<String, dynamic> json) {
    return NUSellUser(
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      phoneNumber: json['phoneNumber'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'gender': gender,
    };
  }
}
