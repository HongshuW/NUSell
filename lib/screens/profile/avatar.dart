import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String avatarUrl;
  final Function onTap;

  const Avatar({this.avatarUrl, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: avatarUrl == null
            ? CircleAvatar(
                radius: 70,
                // backgroundColor: Color.fromRGBO(242, 195, 71, 1),
                child: Icon(Icons.photo_camera),
              )
            : CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(avatarUrl),
              ),
      ),
    );
  }
}
