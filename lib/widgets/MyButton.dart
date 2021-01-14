import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Color color;
  final String text;
  final Function onPressed;
  Icon icon;

  MyButton({
    Key key,
    @required this.color,
    @required this.text,
    @required this.icon,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MaterialButton(
          child: IconTheme(
            data: IconThemeData(color: Colors.white),
            child: icon,
          ),
          onPressed: onPressed,
          color: color,
          shape: CircleBorder(),
        ),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        )
      ],
    );
  }
}
