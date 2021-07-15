import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:orbital2796_nusell/models/review.dart';
import 'package:orbital2796_nusell/screens/offersMade.dart';
import 'package:orbital2796_nusell/services/auth.dart';

class ReviewScreen extends StatefulWidget {
  final String product;
  final String seller;
  const ReviewScreen({Key key, this.product, this.seller}) : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  var _rating;
  TextEditingController commentController = TextEditingController();
  String _comment;
  Review review;

  final FirebaseFirestore db = FirebaseFirestore.instance;
  CollectionReference offersMade = FirebaseFirestore.instance
      .collection('users')
      .doc(AuthService().getCurrentUID())
      .collection('offersMade');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text('Write your review'),
      ),
      body: Center(
        child: Form(
          key: _formkey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How do you rate the seller?',
                      style: TextStyle(fontSize: 16),
                    ),
                    RatingBar.builder(
                      initialRating: 3,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        _rating = rating;
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How would you describe the seller',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'and this transaction?',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: null,
                      decoration: InputDecoration(
                        labelText: "Comment",
                        hintText:
                            "Share some description about seller and the transaction...",
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
                      controller: commentController,
                      onChanged: (value) {
                        _comment = value;
                      },
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      StreamBuilder<DocumentSnapshot>(
                          stream: db
                              .collection('reviews')
                              .doc(widget.seller)
                              .snapshots(),
                          builder: (context, snapshot) {
                            return ElevatedButton(
                              onPressed: () {
                                if (_formkey.currentState.validate()) {
                                  _formkey.currentState.save();
                                  double averageRating = _rating;
                                  if (snapshot.data.data() != null) {
                                    Map<String, dynamic> doc =
                                        snapshot.data.data();
                                    for (var review in doc['reviews']) {
                                      averageRating =
                                          averageRating + review['rating'];
                                    }
                                    averageRating = averageRating /
                                        (doc['reviews'].length + 1);
                                    print(averageRating);
                                  }
                                  review = Review(AuthService().getCurrentUID(),
                                      _rating, _comment, widget.product);
                                  print(widget.seller);
                                  db
                                      .collection('reviews')
                                      .doc(widget.seller)
                                      .set({
                                    'reviews':
                                        FieldValue.arrayUnion([review.toMap()]),
                                    'averageRating': averageRating
                                  }, SetOptions(merge: true));
                                  db
                                      .collection('posts')
                                      .doc(widget.product)
                                      .set({'sellerScore': averageRating},
                                          SetOptions(merge: true));
                                  offersMade.doc(widget.product).set(
                                      {'reviewDone': true},
                                      SetOptions(merge: true));
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          OffersMadeScreen()));
                                } else {
                                  print('unsuccessful!');
                                }
                              },
                              child: Text(
                                'Submit the review',
                                //style: TextStyle(fontSize: 18),
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: Color.fromRGBO(
                                    242, 195, 71, 1), // background
                                onPrimary: Colors.black, // foreground
                              ),
                            );
                          }),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
