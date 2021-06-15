import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  List<dynamic> _imgRef;

  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  CollectionReference posts = FirebaseFirestore.instance.collection('posts');

  updateButton() {
    return Container(
      child: ElevatedButton(onPressed: () {}, child: Text("update")),
    );
  }

  @override
  void initState() {
    _future = db.collection("posts").doc(widget.product).get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    updatePost() {
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
        return posts.doc(this.docId).update({
          'productName': name,
          'description': description,
          'category': category,
          'price': price,
          'location': location,
          'productId': this.docId,
          'nameForSearch':
              name.toLowerCase().trim() + " " + description.toLowerCase().trim()
        }).then((value) => Fluttertoast.showToast(
            msg: 'You have updated this post successfully!',
            gravity: ToastGravity.CENTER));
      }
    }

    displayImages() {
      List<Widget> result = [];
      if (this._imgRef.isEmpty) {
        result.add(Image.network(
            "https://firebasestorage.googleapis.com/v0/b/orbital-test-4e374.appspot.com/o/productpics%2Fdefault%20image.png?alt=media&token=1be9ee11-e256-46f8-81b2-41f1181e44cd"));
      } else {
        for (String img in this._imgRef) {
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
                      content: Image.network(img),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            this._imgRef.remove(img);
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
            child: Image.network(
              img,
              fit: BoxFit.fitWidth,
            ),
          ));
        }
      }
      return result;
    }

    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: BackButton(
          color: Colors.black,
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
          margin: EdgeInsets.all(30),
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
              this._imgRef = post['images'];

              return ListView(
                children: [
                  // Images
                  // Text("Photos: \n"),
                  // GridView.count(
                  //   crossAxisCount: 3,
                  //   crossAxisSpacing: 1,
                  //   mainAxisSpacing: 1,
                  //   shrinkWrap: true,
                  //   children: displayImages(),
                  // ),

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
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Cancel"),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(255, 88, 68, 1),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      updatePost();
                      Navigator.of(context).pop();
                    },
                    child: Text("Update"),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(100, 170, 255, 1),
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
