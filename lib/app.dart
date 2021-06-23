import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/providers/filtersProvider.dart';
import 'package:orbital2796_nusell/providers/postsProvider.dart';
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
        ChangeNotifierProvider(
            create: (context) => postsProvider(),
        ),
        ChangeNotifierProvider(
            create: (context) => filtersProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Login App',
        theme:
            ThemeData(
                accentColor: Color.fromRGBO(242, 195, 71, 1),
                primarySwatch: MaterialColor(0xFFF2C347, {
                  50: Color.fromRGBO(242, 195, 71, .1),
                  100: Color.fromRGBO(242, 195, 71, .2),
                  200: Color.fromRGBO(242, 195, 71, .3),
                  300: Color.fromRGBO(242, 195, 71, .4),
                  400: Color.fromRGBO(242, 195, 71, .5),
                  500: Color.fromRGBO(242, 195, 71, .6),
                  600: Color.fromRGBO(242, 195, 71, .7),
                  700: Color.fromRGBO(242, 195, 71, .8),
                  800: Color.fromRGBO(242, 195, 71, .9),
                  900: Color.fromRGBO(242, 195, 71, 1)
                })),
        home: SignupScreen(),
      ),
    );
  }
}
