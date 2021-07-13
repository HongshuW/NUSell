import 'package:flutter/material.dart';

class popUp extends StatefulWidget {
  String title = "";
  String subtitle = "";
  bool cancelButton = true;
  String confirmText = "OK";
  Color confirmColor = Colors.blue;
  bool hasTextField = false;
  Function confirmAction;
  TextField textField = TextField();

  popUp(
      {Key key,
      this.title,
      this.subtitle = "",
      this.cancelButton = true,
      this.confirmText = "OK",
      this.confirmColor = Colors.blue,
      this.confirmAction,
      this.hasTextField = false,
      this.textField})
      : super(key: key);

  @override
  State<popUp> createState() => _popUpState();
}

class _popUpState extends State<popUp> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 10,
      backgroundColor: Color.fromRGBO(250, 250, 250, 1),
      child: Container(
        margin: EdgeInsets.only(left: 30, right: 30, top: 40, bottom: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // title
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Text(
                widget.title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            // subtitle
            Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.subtitle,
                    style: TextStyle(fontSize: 14),
                  ),
                  widget.hasTextField
                      ? Container(width: 70, child: widget.textField)
                      : Container()
                ],
              ),
            ),

            // actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // cancel button
                widget.cancelButton
                    ? ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          side: BorderSide(color: widget.confirmColor),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(fontSize: 14),
                        ),
                      )
                    : Container(),

                // confirm button
                ElevatedButton(
                    onPressed: widget.confirmAction,
                    style: ElevatedButton.styleFrom(
                        primary: widget.confirmColor,
                        side: BorderSide(color: widget.confirmColor)),
                    child: Text(
                      widget.confirmText,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
