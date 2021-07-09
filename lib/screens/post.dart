import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart';
import 'package:orbital2796_nusell/screens/home.dart';
import 'package:orbital2796_nusell/screens/profile.dart';
import 'package:orbital2796_nusell/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orbital2796_nusell/subProject/custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'dart:io';

class PostScreen extends StatefulWidget {
  PostScreen({Key key}) : super(key: key);
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  String userId;
  String productName;
  String description;
  double price;
  List<File> _images = [];
  List<String> _imgRef = [];
  String docId;
  String location = "UTown";
  String category = "Textbooks";

  CollectionReference posts = FirebaseFirestore.instance.collection('posts');
  FirebaseStorage storage = FirebaseStorage.instance;
  CollectionReference myPosts =
      FirebaseFirestore.instance.collection('myPosts');

  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;
    if (gallery) {
      pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 30,
      );
    } else {
      pickedFile = await picker.getImage(
        source: ImageSource.camera,
        imageQuality: 30,
      );
    }

    setState(() {
      if (pickedFile != null) {
        _images.add(File(pickedFile.path));
      }
    });
  }

  uploadImages() async {
    var len = _images.length;
    for (var i = 0; i < len; i++) {
      var img = _images[i];
      Reference ref = storage.ref().child('productpics/${basename(img.path)}');
      await ref.putFile(File(img.path));
      String url = await ref.getDownloadURL();
      _imgRef.add(url);
    }
    posts.doc(this.docId).update({"images": FieldValue.arrayUnion(_imgRef)});
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    this.userId = auth.currentUser.uid;

    DocumentReference currentUser =
        FirebaseFirestore.instance.collection('users').doc(this.userId);
    List<String> addedPost = [];

    addPost() {
      if (userId == null || userId == "") {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => LoginScreen()));
        Fluttertoast.showToast(
            msg: "Please log in to add a post!", gravity: ToastGravity.CENTER);
      } else if (productName == null || productName == "") {
        Fluttertoast.showToast(
          msg: 'Please enter the name of your product.',
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red,
        );
        return null;
      } else if (description == null || description == "") {
        Fluttertoast.showToast(
          msg: 'Please fill in description of your product.',
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red,
        );
        return null;
      } else if (price == null || price < 0) {
        Fluttertoast.showToast(
          msg: 'Please enter a valid price for your product.',
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.red,
        );
        return null;
      } else {
        return posts
            .add({
              'user': userId,
              'productName': productName,
              'description': description,
              'category': category,
              'price': price,
              'location': location,
              'images': [],
              'time': DateTime.parse(DateTime.now().toString()),
              'searchKey': productName.substring(0, 1).toLowerCase(),
              'nameForSearch': productName.toLowerCase().trim() +
                  description.toLowerCase().trim(),
            })
            .then((docRef) {
              this.docId = docRef.id;
              posts.doc(this.docId).update({"productId": this.docId});
            })
            .then((value) => addedPost.add(this.docId))
            .then((value) => myPosts.doc(userId).set({
                  'myPosts': FieldValue.arrayUnion([this.docId])
                }, SetOptions(merge: true)))
            .then((value) => Fluttertoast.showToast(
                msg: 'You have added a post successfully!',
                gravity: ToastGravity.CENTER))
            .then((value) => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ProfileScreen())));
      }
    }

    displayImages() {
      List<Widget> result = [];
      if (_images.isEmpty) {
        result.add(InkWell(
          onTap: () {
            getImage(true);
          },
          child: Image.asset('assets/images/defaultPostImage.png',
              fit: BoxFit.fitWidth),
        ));
      } else {
        for (File img in _images) {
          result.add(InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: Colors.transparent,
                      title: Container(
                        margin: EdgeInsets.only(right: 180),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Icon(Icons.arrow_back),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white30,
                          ),
                        ),
                      ),
                      content: Image.file(img),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            this._images.remove(img);
                            Navigator.of(context).pop();
                          },
                          child: Text("delete"),
                          style: ElevatedButton.styleFrom(
                            primary: Color.fromRGBO(220, 80, 60, 1),
                          ),
                        ),
                      ],
                    );
                  });
            },
            child: Image.file(
              img,
              fit: BoxFit.fitWidth,
            ),
          ));
        }
      }
      return result;
    }

    return Scaffold(
      appBar: AppBar(
        //on pressed will return back to the home screen
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => HomeScreen()));
          },
        ),
        title: Text(
          'Post an item',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          // on pressed will submit the post and return to the profile screen
          Container(
            margin: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 10.0),
            child: ElevatedButton(
              child: Text("Cancel"),
              style: ElevatedButton.styleFrom(
                primary: Color.fromRGBO(255, 88, 68, 1),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
        backgroundColor: Colors.white70,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomCenter,
              stops: [0.5, 0.5],
              colors: [
                Color.fromRGBO(175, 241, 218, 0.3),
                Color.fromRGBO(249, 234, 143, 0.5),
              ],
            ),
          ),
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: ListView(
            children: <Widget>[
              // name of the product
              Container(
                margin: const EdgeInsets.only(
                    right: 130.0, top: 20.0, bottom: 10.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Name of the Product",
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Color.fromRGBO(242, 195, 71, 1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black45),
                    ),
                    fillColor: Color.fromRGBO(255, 255, 255, 0.5),
                    filled: true,
                  ),
                  controller: TextEditingController(text: this.productName),
                  onChanged: (value) {
                    this.productName = value;
                  },
                ),
              ),

              // display photos
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
                shrinkWrap: true,
                children: displayImages(),
              ),

              // upload photos
              Container(
                margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: Row(
                  children: <Widget>[
                    ElevatedButton(
                      child: Icon(
                        Icons.add_photo_alternate,
                        color: Color.fromRGBO(242, 195, 71, 1),
                      ),
                      onPressed: () {
                        getImage(true);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white70,
                      ),
                    ),
                    ElevatedButton(
                      child: Icon(
                        Icons.add_a_photo,
                        color: Color.fromRGBO(242, 195, 71, 1),
                      ),
                      onPressed: () {
                        getImage(false);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // description of the product
              TextField(
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: null,
                decoration: InputDecoration(
                  labelText: "Description",
                  hintText:
                      "Share some description about the product to sell...",
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Color.fromRGBO(242, 195, 71, 1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45),
                  ),
                  fillColor: Color.fromRGBO(255, 255, 255, 0.5),
                  filled: true,
                ),
                controller: TextEditingController(text: this.description),
                onChanged: (value) {
                  this.description = value;
                },
              ),

              // select categories (subtitle)
              Container(
                margin: const EdgeInsets.only(top: 10.0),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.category,
                        color: Color.fromRGBO(242, 195, 71, 1)),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        color: Colors.white60,
                      ),
                      padding: EdgeInsets.all(5.0),
                      margin: EdgeInsets.only(left: 20, right: 150),
                      child: Text(
                        "Categories",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),

              // select categories (buttons)
              CustomRadioButton(
                defaultSelected: 'Textbooks',
                elevation: 0,
                padding: 0,
                unSelectedColor: Colors.white54,
                enableButtonWrap: true,
                autoWidth: true,
                width: 120,
                wrapAlignment: WrapAlignment.center,
                buttonLables: [
                  'Textbooks',
                  'Notes',
                  'Food',
                  'Appliances',
                  'Electronics',
                  'Cosmetics',
                  'Toys',
                  'Others',
                ],
                buttonValues: [
                  'Textbooks',
                  'Notes',
                  'Food',
                  'Appliances',
                  'Electronics',
                  'Cosmetics',
                  'Toys',
                  'Others',
                ],
                buttonTextStyle: ButtonTextStyle(
                    selectedColor: Colors.white,
                    unSelectedColor: Colors.black,
                    textStyle: TextStyle(fontSize: 12)),
                radioButtonValue: (value) {
                  this.category = value;
                },
                selectedColor: Color.fromRGBO(242, 195, 71, 1),
                unSelectedBorderColor: Colors.white54,
                selectedBorderColor: Color.fromRGBO(242, 195, 71, 1),
              ),

              // Price
              Container(
                margin: const EdgeInsets.only(top: 20.0),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.attach_money,
                      color: Color.fromRGBO(242, 195, 71, 1),
                    ),
                    Container(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          color: Colors.white60,
                        ),
                        padding: EdgeInsets.all(5.0),
                        margin: EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Price",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    Container(
                      width: 70.0,
                      margin: const EdgeInsets.only(left: 140.0),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.all(5),
                          hintText: "e.g. 7.5",
                          fillColor: Color.fromRGBO(255, 255, 255, 0.5),
                          filled: true,
                        ),
                        onChanged: (value) {
                          try {
                            this.price = double.parse(value);
                            if (this.price < 0) {
                              Fluttertoast.showToast(
                                msg: "price is invalid!",
                                gravity: ToastGravity.CENTER,
                                textColor: Colors.red,
                              );
                            }
                          } catch (FormatException) {
                            Fluttertoast.showToast(
                              msg: "Please enter a numerical value!",
                              gravity: ToastGravity.CENTER,
                              textColor: Colors.red,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Location
              Container(
                margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.location_on,
                        color: Color.fromRGBO(242, 195, 71, 1)),
                    Container(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          color: Colors.white60,
                        ),
                        padding: EdgeInsets.all(5.0),
                        margin: EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Location",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // select locations (buttons)
              Container(
                margin: EdgeInsets.only(bottom: 40),
                child: CustomRadioButton(
                  defaultSelected: 'UTown',
                  elevation: 0,
                  padding: 0,
                  unSelectedColor: Colors.white54,
                  enableButtonWrap: true,
                  width: 120,
                  wrapAlignment: WrapAlignment.center,
                  buttonLables: [
                    'UTown',
                    'PGP',
                    'Kent Ridge MRT',
                    'Central Library',
                    'YIH',
                    'Outside NUS',
                    'Others',
                  ],
                  buttonValues: [
                    "UTown",
                    "PGP",
                    "Kent Ridge MRT",
                    'Central Library',
                    'YIH',
                    'Outside NUS',
                    'Others',
                  ],
                  buttonTextStyle: ButtonTextStyle(
                      selectedColor: Colors.white,
                      unSelectedColor: Colors.black,
                      textStyle: TextStyle(fontSize: 12)),
                  radioButtonValue: (value) {
                    this.location = value;
                  },
                  selectedColor: Color.fromRGBO(242, 195, 71, 1),
                  unSelectedBorderColor: Colors.white54,
                  selectedBorderColor: Color.fromRGBO(242, 195, 71, 1),
                ),
              ),

              // cancel button
              Container(
                margin: EdgeInsets.only(bottom: 30, left: 90, right: 90),
                child: ElevatedButton(
                  onPressed: () async {
                    addPost();
                    uploadImages();
                  },
                  child: Text("Post"),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromRGBO(242, 195, 71, 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
