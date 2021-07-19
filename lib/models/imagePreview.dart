import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orbital2796_nusell/providers/imageDeletionProvider.dart';

// This class is only used for images deletion in edit product form.
class imagePreview extends StatefulWidget {
  final String img;
  final imageDeletionProvider deleteProvider;
  imagePreview({Key key, this.img, this.deleteProvider}) : super(key: key);
  @override
  _imagePreviewState createState() => _imagePreviewState();
}

class _imagePreviewState extends State<imagePreview> {
  bool deleted = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
                content: Image.network(widget.img),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      if (this.deleted) {
                        widget.deleteProvider.resume(widget.img);
                        setState(() {
                          this.deleted = false;
                        });
                      } else {
                        widget.deleteProvider.delete(widget.img);
                        setState(() {
                          this.deleted = true;
                        });
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text(deleted ? "resume" : "delete"),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(220, 80, 60, 1),
                    ),
                  )
                ],
              );
            });
      },
      child: Image.network(
        widget.img,
        fit: BoxFit.fitWidth,
      ),
    );
  }
}