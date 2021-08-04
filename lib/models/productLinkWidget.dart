import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class productLinkWidget extends StatefulWidget {
  final String productId;
  final Function action;
  final bool smallPreview;
  productLinkWidget({Key key, this.productId, this.action, this.smallPreview}) : super(key: key);

  @override
  _productLinkWidgetState createState() => _productLinkWidgetState();
}

class _productLinkWidgetState extends State<productLinkWidget> {
  var db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    double imageSize = widget.smallPreview ? 60 : MediaQuery.of(context).size.width * 0.3;
    double textWidth = widget.smallPreview ? 90 : MediaQuery.of(context).size.width * 0.6;
    return StreamBuilder(
        stream: db.collection("posts").doc(widget.productId).snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          Map<String, dynamic> productInfo = snapshot.data.data();
          if (productInfo["status"] != "Selling") {
            return Container();
          }
          return InkWell(
            onTap: widget.action,
            child: Card(
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    child: productInfo["images"].isEmpty
                      ? Image.asset(
                          'assets/images/defaultPreview.png',
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.fill,
                        )
                        : CachedNetworkImage(
                            imageUrl: productInfo["images"][0],
                            width: imageSize,
                            height: imageSize,
                            fit: BoxFit.fill,
                          ),
                  ),
                  Column(
                    children: [
                      Container(
                        width: textWidth,
                        child: Text(
                            productInfo["productName"],
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                        ),
                      ),
                      Container(
                        width: textWidth,
                        child: Text(
                            "\$${productInfo["price"]}",
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        width: textWidth,
                        child: Text(
                            productInfo["description"],
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}