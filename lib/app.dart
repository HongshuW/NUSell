import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/screens/signup.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(accentColor: Colors.orange, primarySwatch: Colors.blue),
      home: SignupScreen(),
    );
  }
}

class ChangeNotifierProvider {}
