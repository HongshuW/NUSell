import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  final String avatarUrl;
  final Function onTap;
  final double size;

  const Avatar({this.avatarUrl, this.onTap, this.size});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: avatarUrl == null
            ? CircleAvatar(
                radius: size,
                // backgroundColor: Color.fromRGBO(242, 195, 71, 1),
                child: Icon(Icons.photo_camera),
              )
            : CircleAvatar(
                radius: size,
                backgroundImage: NetworkImage(avatarUrl),
              ),
      ),
    );
  }
}
