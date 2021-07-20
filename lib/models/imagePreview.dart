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
                elevation: 0,
                title: Container(
                  margin: EdgeInsets.only(right: 180),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    color: Colors.white,
                    icon: Icon(Icons.arrow_back),
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
                      primary: deleted ? Color.fromRGBO(242, 195, 71, 1) : Colors.red
                    ),
                  )
                ],
              );
            });
      },
      child: deleted
          ? Container(
              color: Colors.white30,
              alignment: Alignment.center,
              child: Text("deleted"),
            )
          : Image.network(
              widget.img,
              fit: BoxFit.cover,
            ),
    );
  }
}