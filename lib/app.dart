import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:orbital2796_nusell/main.dart';
import 'package:orbital2796_nusell/providers/filtersProvider.dart';
import 'package:orbital2796_nusell/providers/imageDeletionProvider.dart';
import 'package:orbital2796_nusell/providers/userInfoProvider.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:provider/provider.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    var initialzationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initialzationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Future _showNotification(String body) async {
    //   var androidDetails = AndroidNotificationDetails(
    //       "channelId", "NUSell", "This is channel for chat notifications");
    //   var generalNotificationDetails =
    //       new NotificationDetails(android: androidDetails);

    //   await flutterLocalNotificationsPlugin.show(
    //       0, "New Message", body, generalNotificationDetails);
    // }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      User curr = FirebaseAuth.instance.currentUser;

      if (notification != null && android != null && curr != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channel.description,
                icon: android?.smallIcon,
              ),
            ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => userInfoProvider(),
        ),
        //Provider(create: (context) => ProfileScreen(auth.currentUser.uid)),
        ChangeNotifierProvider(
          create: (context) => filtersProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => imageDeletionProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Login App',
        theme: ThemeData(
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
        home: LoginScreen(),
      ),
    );
  }
}
