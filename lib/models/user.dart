class NUSellUser {
  final String uid;
  String username;
  String phoneNumber;
  String avatarUrl;
  String email;
  String password;
  String gender;
  List<String> myPosts = [];
  List<String> myCart = [];

  NUSellUser(
      {this.uid,
      this.username,
      this.avatarUrl,
      this.phoneNumber,
      this.email,
      this.password,
      this.gender,
      this.myPosts,
      this.myCart});

  factory NUSellUser.fromJson(Map<String, dynamic> json) {
    return NUSellUser(
        username: json['username'],
        avatarUrl: json['avatarUrl'],
        phoneNumber: json['phoneNumber'],
        email: json['email'],
        password: json['password'],
        gender: json['gender'],
        myPosts: List.from(json['posts']),
        myCart: List.from(json['shopping carts']));
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'email': email,
      'password': password,
      'gender': gender,
      'posts': myPosts,
      'shopping carts': myCart
    };
  }
}
