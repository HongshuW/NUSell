import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:orbital2796_nusell/models/forumPost.dart';
import 'package:orbital2796_nusell/screens/forum.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class AddAForumPostScreen extends StatefulWidget {
  AddAForumPostScreen({Key key}) : super(key: key);

  @override
  _AddAForumPostScreenState createState() => _AddAForumPostScreenState();
}

class _AddAForumPostScreenState extends State<AddAForumPostScreen> {
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  var posts = FirebaseFirestore.instance.collection('forumPosts');

  String content = "";
  List<File> _images = [];
  List<String> _imgRef = [];
  String docId;

  Future getImage(bool gallery) async {
    ImagePicker picker = ImagePicker();
    PickedFile pickedFile;
    if (gallery) {
      await Permission.mediaLibrary.request();
      pickedFile = await picker.getImage(
        source: ImageSource.gallery,
        imageQuality: 30,
      );
    } else {
      await Permission.camera.request();
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
      Reference ref = storage.ref().child('forumpics/${basename(img.path)}');
      await ref.putFile(File(img.path));
      String url = await ref.getDownloadURL();
      _imgRef.add(url);
    }
  }

  @override
  Widget build(BuildContext context) {
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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20),
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.fill,
                alignment: Alignment.bottomRight),
          ),
          child: ListView(
            children: [
              // back button
              Container(
                alignment: Alignment.topLeft,
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ForumScreen()));
                    },
                    icon: Icon(Icons.arrow_back, color: Colors.brown)),
              ),

              // title
              Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 30, bottom: 60),
                  child: Text(
                    "Publish a Forum Post",
                    style: TextStyle(
                        color: Colors.brown,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  )),

              // content
              Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: "Content",
                    hintText: "e.g. Is anyone selling XXX? ...",
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
                  controller: TextEditingController(text: this.content),
                  onChanged: (value) {
                    this.content = value;
                  },
                ),
              ),

              // display photos
              Container(
                margin: EdgeInsets.only(top: 30, left: 30, right: 30),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  shrinkWrap: true,
                  children: displayImages(),
                ),
              ),

              // upload photos
              Container(
                margin: const EdgeInsets.only(top: 10, left: 30),
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

              // publish
              Container(
                margin:
                    EdgeInsets.only(top: 30, bottom: 50, left: 100, right: 100),
                child: ElevatedButton(
                    onPressed: () async {
                      if (this.content == "") {
                        Fluttertoast.showToast(
                            msg: "Please enter content of the post.",
                            gravity: ToastGravity.CENTER);
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                backgroundColor: Colors.transparent,
                                child: Center(
                                    child: CircularProgressIndicator(
                                        //color: Colors.white
                                        )),
                              );
                            });
                        await uploadImages();
                        forumPost post = forumPost(
                            userID: auth.currentUser.uid,
                            content: this.content,
                            images: this._imgRef);
                        post.addAPost(context);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ForumScreen()));
                        Fluttertoast.showToast(
                            msg:
                                "You have published a forum post successfully!",
                            gravity: ToastGravity.CENTER);
                      }
                    },
                    child:
                        Text("Publish", style: TextStyle(color: Colors.brown))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
