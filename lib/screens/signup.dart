import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orbital2796_nusell/models/user.dart';
import 'package:orbital2796_nusell/screens/home.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:orbital2796_nusell/screens/reset.dart';
import 'package:orbital2796_nusell/screens/verify.dart';
import 'package:orbital2796_nusell/services/db.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String _username, _email, _password, _confirmPassword;
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  final auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color.fromRGBO(255, 255, 255, 1.0),
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(252, 228, 70, 1),
          title: Text(
            'NUSell',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Center(
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(hintText: 'Username'),
                    onChanged: (value) {
                      setState(() {
                        _username = value.trim();
                      });
                    },
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(hintText: 'Email'),
                    onChanged: (value) {
                      setState(() {
                        _email = value.trim();
                      });
                    },
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: password,
                    obscureText: true,
                    decoration: InputDecoration(hintText: 'Password'),
                    onChanged: (value) {
                      setState(() {
                        _password = value.trim();
                      });
                    },
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Please enter password';
                      }

                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: confirmPassword,
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'Please re-enter password';
                      }

                      if (confirmPassword.text != _password) {
                        return 'Password does not match';
                      }

                      return null;
                    },
                    obscureText: true,
                    decoration: InputDecoration(hintText: 'Confirm Password'),
                    onChanged: (value) {
                      setState(() {
                        _confirmPassword = value.trim();
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('New user? Welcome!'),
                        ElevatedButton(
                          onPressed: () {
                            if (_formkey.currentState.validate()) {
                              print('successful!');
                              _signup(_email, _password);
                            } else {
                              print('unsuccessful!');
                            }
                          },
                          child: Text(
                            'Sign Up',
                            //style: TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary:
                                Color.fromRGBO(242, 195, 71, 1), // background
                            onPrimary: Colors.black, // foreground
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Or already have an account?'),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          },
                          child: Text('Sign In'),
                          style: ElevatedButton.styleFrom(
                            primary:
                                Color.fromRGBO(242, 195, 71, 1), // background
                            onPrimary: Colors.black, // foreground
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => ResetScreen())),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(fontSize: 16),
                        ))
                  ],
                ),
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Positioned(
                        child: Image.asset('assets/images/wavingLion.png'))
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  _signup(String _email, String _password) async {
    try {
      UserCredential cred = await auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      User firebaseUser = cred.user;
      NUSellUser user = NUSellUser(
          uid: firebaseUser.uid,
          username: _username,
          email: _email,
          password: _password);
      print(user.uid);
      await DatabaseService(uid: user.uid).updateUserData(user);
      print(user.uid);
      //Success
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => VerifyScreen()));
    } on FirebaseAuthException catch (error) {
      print(error.message);
      Fluttertoast.showToast(msg: error.message, gravity: ToastGravity.TOP);
    }
  }
}
