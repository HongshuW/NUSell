class Comment {
  String content;
  String user;

  Comment({this.content, this.user});

  Map<String, dynamic> toMap() {
    return {'user': this.user, 'message': this.content, 'replies': []};
  }
}

class Reply extends Comment {
}