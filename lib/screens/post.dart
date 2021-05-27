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
import 'dart:io';

enum Categories { textbooks, notes, homeApplicances, toysAndGames,
  electronics, cosmetics }

enum Locations { UTown, PGP, MRT, CentralLibrary }

class PostScreen extends StatefulWidget {
  PostScreen({Key key}) : super(key: key);
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  String userId;
  String productName;
  String description;
  Categories _category = Categories.textbooks;
  double price;
  Locations _location = Locations.UTown;
  List<File> _images = [];
  List<String> _imgRef = [];
  String docId;

  FirebaseStorage storage = FirebaseStorage.instance;

  String categoryToString(Categories cat) {
    if (cat == Categories.textbooks) {
      return 'Textbooks';
    } else if (cat == Categories.notes) {
      return 'Notes';
    } else if (cat == Categories.homeApplicances) {
      return 'Home Applicances';
    } else if (cat == Categories.toysAndGames) {
      return 'Toys & Games';
    } else if (cat == Categories.electronics) {
      return 'Electronics';
    } else if (cat == Categories.cosmetics) {
      return 'Cosmetics';
    } else {
      return '';
    }
  }

  String locationToString(Locations loc) {
    if (loc == Locations.UTown) {
      return "UTown";
    } else if (loc == Locations.PGP) {
      return "PGP";
    } else if (loc == Locations.MRT) {
      return "MRT";
    } else if (loc == Locations.CentralLibrary) {
      return "Central Library";
    } else {
      return "";
    }
  }

  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;
    if (gallery) {
      pickedFile = await picker.getImage(source: ImageSource.gallery);
    } else {
      pickedFile = await picker.getImage(source: ImageSource.camera);
    }

    setState(() {
      if (pickedFile != null) {
        _images.add(File(pickedFile.path));
        _imgRef.add('productpics/${basename(pickedFile.path)}');
      } else {
        print("no image picked!");
      }
    });
  }

  uploadImages() async {
    _images.forEach((img) async {
      storage.ref()
          .child('productpics/${basename(img.path)}')
          .putFile(File(img.path));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Direct to the `posts` collection.
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');

    FirebaseAuth auth = FirebaseAuth.instance;
    this.userId = auth.currentUser.uid;

    DocumentReference currentUser = FirebaseFirestore.instance
        .collection('users').doc(this.userId);
    List<String> addedPost = List<String>();

    addPost(productName) {
      if (userId == null || userId == "") {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => LoginScreen()));
        Fluttertoast.showToast(
          msg: "Please log in to add a post!",
          gravity: ToastGravity.CENTER);
      } else if (productName == null || productName == "") {
        Fluttertoast.showToast(
            msg: 'Please enter the name of your product.',
            gravity: ToastGravity.TOP,
            textColor: Colors.red,
        );
        return null;
      } else if (description == null || description == "") {
        Fluttertoast.showToast(
            msg: 'Please fill in description of your product.',
            gravity: ToastGravity.TOP,
          textColor: Colors.red,
        );
        return null;
      } else if (price == null) {
        Fluttertoast.showToast(
            msg: 'Please enter a valid price for your product.',
            gravity: ToastGravity.TOP,
          textColor: Colors.red,
        );
        return null;
      } else {
        uploadImages();
        return posts.add({
          'user': userId,
          'productName': productName,
          'description': description,
          'category': categoryToString(_category),
          'price': price,
          'location': locationToString(_location),
          'images': _imgRef
        })
            .then((docRef) => this.docId = docRef.id)
            .then((value) => addedPost.add(this.docId))
            .then((value) => currentUser.update({"posts": FieldValue.arrayUnion(addedPost)}))
            .then((value) => Fluttertoast.showToast(
              msg: 'You have added a post successfully!',
              gravity: ToastGravity.CENTER))
            .then((value) => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => ProfileScreen())))
            .catchError((error) => print('Fail to add a post: $error'));
      }
    }

    switchCategory(Categories value) {
      setState(() {
        _category = value;
      });
    }

    switchLocation(Locations value) {
      setState(() {
        _location = value;
      });
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
            child: RaisedButton(
              child: Text("POST"),
              color: Color.fromRGBO(252, 228, 70, 1),
              onPressed: (){addPost(this.productName);},
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
              colors: [
                Color.fromRGBO(175, 241, 218, 0.7),
                Color.fromRGBO(249, 234, 143, 0.7),
              ],
            ),
          ),
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: ListView(children: <Widget>[
            // name of the product
            Container(
              margin: const EdgeInsets.only(right: 130.0, top: 20.0),
              child: TextField(
                decoration: InputDecoration(
                    labelText: "Name of the Product",
                    isDense: true,
                    contentPadding: EdgeInsets.all(10),
                    focusedBorder:OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black45),
                    ),
                    fillColor: Color.fromRGBO(255, 255, 255, 0.5),
                    filled: true,
                ),
                onChanged: (value){
                  this.productName = value;
                },
              ),
            ),

            // upload photos
            Container(
              margin: const EdgeInsets.only(top: 50.0, bottom: 50.0),
              child: Row(children: <Widget>[
                RaisedButton(
                  child: Icon(
                    Icons.add_photo_alternate,
                    color: Color.fromRGBO(242, 195, 71, 1),
                  ),
                  onPressed: (){getImage(true);},
                  color: Colors.white70,
                ),
                RaisedButton(
                  child: Icon(
                    Icons.add_a_photo,
                    color: Color.fromRGBO(242, 195, 71, 1),
                  ),
                  onPressed: (){getImage(false);},
                  color: Colors.white70,
                ),
              ],),
            ),

            // description of the product
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              decoration: InputDecoration(
                  labelText: "Description",
                  hintText: "Share some description about the product to sell...",
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45),
                  ),
                  fillColor: Color.fromRGBO(255, 255, 255, 0.5),
                  filled: true,
              ),
              onChanged: (value){
                this.description = value;
              },
            ),

            // select categories (subtitle)
            Container(
              margin: const EdgeInsets.only(top: 10.0),
              child: Row(children: <Widget>[
                Icon(
                  Icons.category,
                  color: Color.fromRGBO(242, 195, 71, 1)
                ),
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
              ],),
            ),

            // select categories (buttons)
            Container(
              child: Column(children: <Widget>[
                RadioListTile<Categories>(
                  title: const Text('Textbooks'),
                  value: Categories.textbooks,
                  groupValue: _category,
                  onChanged: switchCategory,
                ),
                RadioListTile<Categories>(
                    title: const Text('Notes'),
                    value: Categories.notes,
                    groupValue: _category,
                    onChanged: switchCategory,
                ),
                RadioListTile<Categories>(
                  title: const Text('Home Applicances'),
                  value: Categories.homeApplicances,
                  groupValue: _category,
                  onChanged: switchCategory,
                ),
                RadioListTile<Categories>(
                  title: const Text('Toys & Games'),
                  value: Categories.toysAndGames,
                  groupValue: _category,
                  onChanged: switchCategory,
                ),
                RadioListTile<Categories>(
                  title: const Text('Electronics'),
                  value: Categories.electronics,
                  groupValue: _category,
                  onChanged: switchCategory,
                ),
                RadioListTile<Categories>(
                  title: const Text('Cosmetics'),
                  value: Categories.cosmetics,
                  groupValue: _category,
                  onChanged: switchCategory,
                ),
              ],),
            ),

            // Price
            Container(
              margin: const EdgeInsets.only(top: 20.0),
              child: Row(children: <Widget>[
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
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(5),
                      hintText: "e.g. 7.5",
                      fillColor: Color.fromRGBO(255, 255, 255, 0.5),
                      filled: true,
                    ),
                    onChanged: (value){
                      try {
                        this.price = double.parse(value);
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
              ],),
            ),

            // Location
            Container(
              margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Row(children: <Widget>[
                Icon(
                  Icons.location_on,
                    color: Color.fromRGBO(242, 195, 71, 1)
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
                      "Location",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],),
            ),

            // select locations (buttons)
            Container(
              child: Column(children: <Widget>[
                RadioListTile<Locations>(
                  title: const Text('UTown'),
                  value: Locations.UTown,
                  groupValue: _location,
                  onChanged: switchLocation,
                ),
                RadioListTile<Locations>(
                  title: const Text('PGP'),
                  value: Locations.PGP,
                  groupValue: _location,
                  onChanged: switchLocation,
                ),
                RadioListTile<Locations>(
                  title: const Text('Kent Ridge MRT'),
                  value: Locations.MRT,
                  groupValue: _location,
                  onChanged: switchLocation,
                ),
                RadioListTile<Locations>(
                  title: const Text('Central Library'),
                  value: Locations.CentralLibrary,
                  groupValue: _location,
                  onChanged: switchLocation,
                ),
              ],),
            ),
          ],),
        ),
      ),
    );
  }
}