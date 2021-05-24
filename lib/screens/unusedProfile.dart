import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/models/user.dart';
import 'package:orbital2796_nusell/providers/userInfoProvider.dart';
import 'package:orbital2796_nusell/screens/home.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:orbital2796_nusell/screens/post.dart';
import 'package:orbital2796_nusell/services/auth.dart';
import 'package:provider/provider.dart';

// class ProfileScreen extends StatefulWidget {
//   // final NUSellUser user;
//   // ProfileScreen({this.user});
//   const ProfileScreen({this.uid});
//   final String uid;
//   // const ProfileScreen({this.uid});
//   @override
//   _ProfileScreenState createState() => _ProfileScreenState(this.uid);
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final String uid;
//   _ProfileScreenState(this.uid);
//   final auth = FirebaseAuth.instance;
//   // String uid = AuthService().getCurrentUID();
//   // // final Stream<QuerySnapshot> _userInfo =
//   // //     FirebaseFirestore.instance.collection('users').doc(this.uid).snapshots();

//   // @override
//   // Widget build(BuildContext context) {
//   //   CollectionReference users = FirebaseFirestore.instance.collection('users');
//   //   print(uid);
//   //   return FutureBuilder<DocumentSnapshot>(
//   //       future: users.doc(uid).get(),
//   //       builder: (context, snapshot) {
//   //         if (snapshot.hasError) {
//   //           return Text('Something went wrong');
//   //         }

//   //         if (snapshot.hasData && !snapshot.data.exists) {
//   //           return Text('Document does not exist');
//   //         }

//   //         if (snapshot.connectionState == ConnectionState.waiting) {
//   //           return Text('Loading');
//   //         }
//   //         Map<String, dynamic> data = snapshot.data.data();

//   //         return Scaffold(
//   //           appBar: AppBar(
//   //             title: Text(
//   //               "Name: ${data['username']}",
//   //               style: TextStyle(color: Colors.black),
//   //             ),
//   //             backgroundColor: Colors.white,
//   //           ),
//   //           body: Padding(
//   //             child: Text("Email: ${data['email']}"),
//   //           ),
//   //         );
//   //       });
//   // }
//   //NUSellUser user = NUSellUser();

//   // @override
//   void initState() {
//     final userinfoProvider =
//         Provider.of<userInfoProvider>(context, listen: false);
//     String uid = FirebaseAuth.instance.currentUser.uid;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final userinfoProvider =
//     //     Provider.of<userInfoProvider>(context, listen: false);
//     CollectionReference users = FirebaseFirestore.instance.collection('users');
//     //DocumentSnapshot data = users.doc(uid).snapshots();
//     return FutureBuilder<DocumentSnapshot>(
//         future: users.doc(uid).get(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Text('Something went wrong');
//           }

//           if (snapshot.hasData && !snapshot.data.exists) {
//             return Text('Document does not exist');
//           }

//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Text('Loading');
//           }
//           Map<String, dynamic> data = snapshot.data.data();

//           return Scaffold(
//             appBar: AppBar(
//               title: Text(
//                 "Name: ${data['username']}",
//                 style: TextStyle(color: Colors.black),
//               ),
//               backgroundColor: Colors.white,
//             ),
//             body: Padding(
//               child: Text("Email: ${data['email']}"),
//             ),
//           );
//         });
//   }
    // return Scaffold(
    //   body: Column(
    //     children: [
    //       Center(
    //           child: Row(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           ElevatedButton(
    //             child: Text('Log Out'),
    //             onPressed: () {
    //               auth.signOut();
    //               Navigator.of(context).pushReplacement(
    //                   MaterialPageRoute(builder: (context) => LoginScreen()));
    //             },
    //           ),
    //           ElevatedButton(
    //             child: Text('Delete Account'),
    //             onPressed: () {
    //               User user = FirebaseAuth.instance.currentUser;
    //               user.delete();
    //               print('Deleted successfully!');
    //               Navigator.of(context).pushReplacement(
    //                   MaterialPageRoute(builder: (context) => LoginScreen()));
    //             },
    //           ),
    //         ],
    //       )),
    //     ],
    //   ),

    //   //a collection of the three buttons
    //   floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    //   floatingActionButton: Padding(
    //     padding: const EdgeInsets.all(16.0),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: <Widget>[
    //         FloatingActionButton(
    //           heroTag: "home",
    //           onPressed: () {
    //             Navigator.of(context).push(
    //                 MaterialPageRoute(builder: (context) => HomeScreen()));
    //           },
    //           child: Icon(Icons.house),
    //         ),
    //         FloatingActionButton(
    //           heroTag: "post",
    //           onPressed: () {
    //             Navigator.of(context).push(
    //                 MaterialPageRoute(builder: (context) => PostScreen()));
    //           },
    //           child: Icon(Icons.add),
    //         ),
    //         FloatingActionButton(
    //           heroTag: "profile",
    //           onPressed: () {},
    //           child: Icon(Icons.person),
    //         )
    //       ],
    //     ),
    //   ),
    // );
  // }

//   _getProfileData() async {
//     final uid = await Provider.of<AuthService>(context).getCurrentUID();
//     await Provider.of(context)
//         .db
//         .collection('users')
//         .document(uid)
//         .get()
//         .then((result) {
//       //user.username = result.data['username'];
//       //user.email = result.data['email'];
//     });
//   }

//   Widget displayUserInformation(context, snapshot) {
//     final authData = snapshot.data;

//     return Column(
//       children: [
//         Padding(
//             padding: const EdgeInsets.only(top: 10.0),
//             child: Provider.of<AuthService>(context).getProfileImage()),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text(
//             "Name: ${authData.displayname}",
//             style: TextStyle(fontSize: 20),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text(
//             "Name: ${authData.email}",
//             style: TextStyle(fontSize: 20),
//           ),
//         ),
//       ],
//     );
//   }
// }