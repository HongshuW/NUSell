import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:orbital2796_nusell/screens/settings.dart';
import 'package:orbital2796_nusell/services/auth.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key key}) : super(key: key);

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  String _currentPassword, _newPassword, _confirmPassword;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController currentPassword = TextEditingController();
  TextEditingController newPassword = TextEditingController();
  bool _obscureText = true;
  bool checkCurrentPasswordValid = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset your password'),
        leading: BackButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Navigator.of(context).pushReplacement(
            //     MaterialPageRoute(builder: (context) => ProfileScreen()));
          },
        ),
      ),
      body: Container(
          child: Center(
              child: Form(
                  key: _formkey,
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Current Password',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            TextFormField(
                              //controller: controller,
                              style: TextStyle(fontSize: 20),
                              obscureText: _obscureText,
                              keyboardType: TextInputType.visiblePassword,
                              controller: currentPassword,
                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(25.0),
                                borderSide: new BorderSide(),
                              )),
                              onChanged: (value) {
                                setState(() {
                                  _currentPassword = value.trim();
                                });
                              },
                              onSaved: (value) {
                                setState(() {
                                  _currentPassword = value.trim();
                                });
                              },
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.start,
                            //   children: [
                            //     IconButton(
                            //         icon: _obscureText
                            //             ? Icon(
                            //                 Icons.check_box_outline_blank_sharp)
                            //             : Icon(Icons.check_box_outlined),
                            //         onPressed: _toggle),
                            //     Text(_obscureText
                            //         ? "Show Password"
                            //         : "Hide Password"),
                            //   ],
                            // )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'New Password',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                            TextFormField(
                              //controller: controller,
                              style: TextStyle(fontSize: 20),
                              obscureText: _obscureText,
                              keyboardType: TextInputType.visiblePassword,
                              controller: newPassword,
                              decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(25.0),
                                borderSide: new BorderSide(),
                              )),
                              onChanged: (value) {
                                setState(() {
                                  _newPassword = value.trim();
                                });
                              },
                              onSaved: (value) {
                                setState(() {
                                  _newPassword = value.trim();
                                });
                              },
                              validator: (String value) {
                                if (value.isEmpty) {
                                  return 'Please enter your new password';
                                }
                                return null;
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                    icon: _obscureText
                                        ? Icon(
                                            Icons.check_box_outline_blank_sharp)
                                        : Icon(Icons.check_box_outlined),
                                    onPressed: _toggle),
                                Text(_obscureText
                                    ? "Show Password"
                                    : "Hide Password"),
                              ],
                            )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  checkCurrentPasswordValid =
                                      await AuthService().validatePassword(
                                          currentPassword.text);
                                  if (_formkey.currentState.validate() &&
                                      checkCurrentPasswordValid) {
                                    _formkey.currentState.save();
                                    FirebaseAuth.instance.currentUser
                                        .updatePassword(_newPassword);
                                    print('saved');
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SettingsScreen()));
                                    Fluttertoast.showToast(
                                        msg:
                                            'You have successfully updated your password!');
                                  } else {
                                    print('unsuccessful!');
                                  }
                                },
                                child: Text(
                                  'Save new password',
                                  //style: TextStyle(fontSize: 18),
                                ),
                                style: ElevatedButton.styleFrom(
                                  primary: Color.fromRGBO(
                                      242, 195, 71, 1), // background
                                  onPrimary: Colors.black, // foreground
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  )))),
    );
  }
}
