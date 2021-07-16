import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class loading extends StatefulWidget {
  String message = "";
  bool hasMessage = false;
  String imagePath = "";
  bool hasImage = false;
  bool hasProgressIndicator = true;

  loading(
      {Key key,
        this.message = "",
        this.hasMessage = false,
        this.imagePath = "",
        this.hasImage = false,
        this.hasProgressIndicator = true,
      })
      : super(key: key);

  @override
  State<loading> createState() => _loadingState();
}

class _loadingState extends State<loading> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.hasImage
                  ? Container(
                      height: 100,
                      decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(widget.imagePath),
                        fit: BoxFit.fitHeight
                      )
                    ),
                  ) : Container(),

              widget.hasMessage
                  ? Container(
                    margin: EdgeInsets.only(top: 20, bottom: 20),
                    child: Text(widget.message,
                      style: TextStyle(
                        fontSize: 20,
                        color: Color.fromRGBO(242, 195, 71, 1)
                      ),
                    ),
                  ) : Container(),

              widget.hasProgressIndicator
                  ? CircularProgressIndicator() : Container(),
            ],
          )
      ),
    );
  }
}