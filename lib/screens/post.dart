import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/screens/home.dart';

class PostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //on pressed will return back to the home screen
        leading: BackButton(
          color: Colors.yellow,
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HomeScreen()));
          },
        ),
        title: Text('To post an item'),
      ),
    );
  }
}
