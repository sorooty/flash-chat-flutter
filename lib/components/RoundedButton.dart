import 'package:flutter/material.dart';

class wRoundedButton extends StatelessWidget {
  wRoundedButton(
      {required this.wColor, required this.wText, required this.wOnpressed});

  final Color wColor;
  final String wText;
  final VoidCallback? wOnpressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: wColor,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: wOnpressed,
          minWidth: 200.0,
          height: 45.0,
          child: Text(wText),
        ),
      ),
    );
  }
}
