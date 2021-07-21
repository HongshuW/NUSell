import 'dart:io';
import 'package:orbital2796_nusell/models/imagePreview.dart';
import 'package:orbital2796_nusell/models/loading.dart';
import 'package:orbital2796_nusell/providers/imageDeletionProvider.dart';
import 'package:path/path.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:orbital2796_nusell/subProject/custom_radio_grouped_button/custom_radio_grouped_button.dart';

class EditProductScreen extends StatefulWidget {
  final String product;
  EditProductScreen({Key key, this.product}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  Future<DocumentSnapshot> _future;
  String docId;
  String name;
  double price;
  String location;
  String category;
  String description;
  List<File> _images = [];
  List<String> _imgRef = [];

  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  CollectionReference posts = FirebaseFirestore.instance.collection('posts');

  @override
  void initState() {
    _future = db.collection("posts").doc(widget.product).get();
    super.initState();
  }

  // Get image from device.
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

  // upload images to firebase storage
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
    var deleteProvider = imageDeletionProvider();

    updatePost() async {
      if (name == null || name == "") {
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
        posts.doc(this.docId).update({
          'productName': name,
          'description': description,
          'category': category,
          'price': price,
          'location': location,
          'productId': this.docId,
          'nameForSearch':
              name.toLowerCase().trim() + " " + description.toLowerCase().trim()
        });
      }
    }

    // display original images from firebase
    displayOriginalImages() {
      return StreamBuilder(
        stream: db.collection("posts").doc(widget.product).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          if (snapshot.data['images'].isEmpty) {
            return GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
              shrinkWrap: true,
              children: [
                Image.asset('assets/images/defaultPostImage.png',
                    fit: BoxFit.cover)
              ],
            );
          }
          return GridView.count(
            crossAxisCount: 3,
            crossAxisSpacing: 1,
            mainAxisSpacing: 1,
            shrinkWrap: true,
            children: snapshot.data['images'].map<Widget>((img) {
              return imagePreview(img: img, deleteProvider: deleteProvider);
            }).toList(),
          );
        },
      );
    }

    // delete images from firebase storage
    deleteSelectedImages(String docId) async {
      List<String> deleted = deleteProvider.deleted;
      db.collection("posts").doc(docId)
          .update({"images": FieldValue.arrayRemove(deleted)});
      for (var img in deleted) {
        storage.refFromURL(img).delete();
      }
    }

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Update your product",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color.fromRGBO(249, 241, 219, 1),
            image: DecorationImage(
                image: AssetImage("assets/images/waveTop.png"),
                fit: BoxFit.fitWidth,
                alignment: Alignment.topLeft),
          ),
          padding: EdgeInsets.only(left: 30, right: 30),
          child: FutureBuilder<DocumentSnapshot>(
            future: this._future,
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              Map<String, dynamic> post = snapshot.data.data();
              this.docId = widget.product;
              this.name = post['productName'];
              this.price = post['price'];
              this.location = post['location'];
              this.category = post['category'];
              this.description = post['description'];

              return ListView(
                children: [
                  // Images
                  Container(
                      margin: EdgeInsets.only(top: 30, bottom: 10),
                      child: Text("Original Photos:")),
                  displayOriginalImages(),
                  Container(
                      margin: EdgeInsets.only(top: 30, bottom: 10),
                      child: Text("Added Photos:")),
                  GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 1,
                    shrinkWrap: true,
                    children: _images.isEmpty
                      ? [InkWell(
                          onTap: () {getImage(true);},
                          child: Image.asset(
                            'assets/images/defaultPostImage.png',
                            fit: BoxFit.cover),
                          )]
                      : _images.map((img) {
                        return InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
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
                                        setState(() {
                                          this._images.remove(img);
                                        });
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
                            fit: BoxFit.cover,
                          ),
                        );
                      }).toList()
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

                  // Product Name
                  Text("\n\nProduct Name: "),
                  TextField(
                    controller: TextEditingController(text: "${this.name}"),
                    onChanged: (value) {
                      this.name = value;
                    },
                  ),

                  // Price
                  Text("\n\nPrice (in SGD): "),
                  TextField(
                    controller: TextEditingController(text: "${this.price}"),
                    onChanged: (value) {
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

                  // Description
                  Text("\n\nDescription: "),
                  TextField(
                    minLines: 1,
                    maxLines: null,
                    controller:
                        TextEditingController(text: "${this.description}"),
                    onChanged: (value) {
                      this.description = value;
                    },
                  ),

                  // Category
                  Text("\n\nCategory: "),
                  CustomRadioButton(
                    defaultSelected: this.category,
                    elevation: 0,
                    padding: 0,
                    unSelectedColor: Colors.white54,
                    enableButtonWrap: true,
                    width: 92,
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
                    unSelectedBorderColor: Color.fromRGBO(242, 195, 71, 1),
                    selectedBorderColor: Color.fromRGBO(242, 195, 71, 1),
                  ),

                  // Location
                  Text("\n\nLocation: "),
                  CustomRadioButton(
                    defaultSelected: this.location,
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
                    unSelectedBorderColor: Color.fromRGBO(242, 195, 71, 1),
                    selectedBorderColor: Color.fromRGBO(242, 195, 71, 1),
                  ),

                  // Actions
                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("Cancel"),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(255, 88, 68, 1),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 30),
                    child: ElevatedButton(
                      onPressed: () async {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              print("success");
                              return loading(
                                hasImage: true,
                                imagePath: 'assets/images/wavingLion.png',
                                hasMessage: true,
                                message: "Updating...",
                              );
                            }
                        );
                        await updatePost();
                        await deleteSelectedImages(docId);
                        await uploadImages();
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        Fluttertoast.showToast(
                            msg: 'You have updated this post successfully!',
                            gravity: ToastGravity.CENTER);
                      },
                      child: Text("Update"),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromRGBO(100, 170, 255, 1),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
