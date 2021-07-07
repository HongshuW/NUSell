import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/models/user.dart';
import 'package:orbital2796_nusell/screens/reset.dart';
import 'package:orbital2796_nusell/screens/signup.dart';
import 'package:orbital2796_nusell/services/auth.dart';

NUSellUser currentUser;

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _email, _password;
  TextEditingController password = TextEditingController();
  bool _obscureText = true;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

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
      body: Container(
        child: Center(
          child: Form(
            key: _formkey,
            child: ListView(
              children: [
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: TextFormField(
                //     keyboardType: TextInputType.emailAddress,
                //     decoration: InputDecoration(hintText: 'Email'),
                //     onChanged: (value) {
                //       setState(() {
                //         _email = value.trim();
                //       });
                //     },
                //     validator: (String value) {
                //       if (value.isEmpty) {
                //         return 'Please enter your email';
                //       }
                //       return null;
                //     },
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      TextFormField(
                        //controller: controller,
                        style: TextStyle(fontSize: 20),
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                            border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(25.0),
                          borderSide: new BorderSide(),
                        )),
                        onChanged: (value) {
                          setState(() {
                            _email = value.trim();
                          });
                        },
                        onSaved: (value) {
                          setState(() {
                            _email = value.trim();
                          });
                        },
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: TextFormField(
                //     controller: password,
                //     obscureText: true,
                //     decoration: InputDecoration(hintText: 'Password'),
                //     onChanged: (value) {
                //       setState(() {
                //         _password = value.trim();
                //       });
                //     },
                //     validator: (String value) {
                //       if (value.isEmpty) {
                //         return 'Please enter password';
                //       }

                //       return null;
                //     },
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'Password',
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      TextFormField(
                        //controller: controller,
                        style: TextStyle(fontSize: 20),
                        obscureText: _obscureText,
                        keyboardType: TextInputType.visiblePassword,
                        controller: password,
                        decoration: InputDecoration(
                            border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(25.0),
                          borderSide: new BorderSide(),
                        )),
                        onChanged: (value) {
                          setState(() {
                            _password = value.trim();
                          });
                        },
                        onSaved: (value) {
                          setState(() {
                            _password = value.trim();
                          });
                        },
                        validator: (String value) {
                          if (value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                              icon: _obscureText
                                  ? Icon(Icons.check_box_outline_blank_sharp)
                                  : Icon(Icons.check_box_outlined),
                              onPressed: _toggle),
                          Text(
                              _obscureText ? "Show Password" : "Hide Password"),
                        ],
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formkey.currentState.validate()) {
                          print('successful!');
                          AuthService().signin(_email, _password, context);
                        } else {
                          print('unsuccessful!');
                        }
                      },
                      child: Text('Sign In'),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(242, 195, 71, 1), // background
                        onPrimary: Colors.black, // foreground
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => SignupScreen()));
                      },
                      child: Text('Sign Up'),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(242, 195, 71, 1), // background
                        onPrimary: Colors.black, // foreground
                      ),
                    )
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
                        child: Image.asset('assets/images/wavingLion.png',
                            width: MediaQuery.of(context).size.width * 0.7))
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
