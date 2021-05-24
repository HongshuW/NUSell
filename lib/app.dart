import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/providers/userInfoProvider.dart';
import 'package:orbital2796_nusell/screens/home.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:orbital2796_nusell/screens/signup.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => userInfoProvider(),
        ),
        //Provider(create: (context) => ProfileScreen(auth.currentUser.uid)),
      ],
      child: MaterialApp(
        title: 'Login App',
        theme:
            ThemeData(accentColor: Colors.orange, primarySwatch: Colors.blue),
        home: SignupScreen(),
      ),
    );
  }
}
