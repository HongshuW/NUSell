class Chat {
  // a list of user IDs.
  List<String> users;

  Chat(this.users);

  Map<String, dynamic> toMap() {
    return {
      'users': users,
      'history': []
    };
  }
}