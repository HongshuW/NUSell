import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/models/loading.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:orbital2796_nusell/screens/reset.dart';
import 'package:orbital2796_nusell/services/auth.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String _email, _password, _confirmPassword;
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          backgroundColor: Color.fromRGBO(255, 255, 255, 1.0),
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'NUSell',
              style: TextStyle(color: Colors.black),
            ),
            automaticallyImplyLeading: false,
          ),
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    "assets/images/waveBottom.png",
                  ),
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomRight),
            ),
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
                            controller: confirmPassword,
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
                                'Confirm Password',
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
                                _confirmPassword = value.trim();
                              });
                            },
                            onSaved: (value) {
                              setState(() {
                                _confirmPassword = value.trim();
                              });
                            },
                            validator: (String value) {
                              if (value.isEmpty) {
                                return 'Please re-enter password';
                              }

                              if (confirmPassword.text != _password) {
                                return 'Password does not match';
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
                            Text('New user? Welcome!'),
                            ElevatedButton(
                              onPressed: () {
                                if (_formkey.currentState.validate()) {
                                  print('successful!');
                                  AuthService()
                                      .signup(_email, _password, context);
                                } else {
                                  print('unsuccessful!');
                                }
                              },
                              child: Text(
                                'Sign Up',
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
                        Column(
                          children: [
                            Text('Or already have an account?'),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginScreen()));
                              },
                              child: Text('Sign In'),
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
          )),
    );
  }
}
