class Comment {
  String content;
  String user;
  String mention;

  Comment({this.content, this.user, this.mention});

  Map<String, dynamic> toMap() {
    return {'user': user, 'message': content, 'mention': mention};
  }
}