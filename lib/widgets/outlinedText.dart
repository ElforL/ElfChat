import 'package:flutter/material.dart';

class OutlinedText extends StatelessWidget {
  const OutlinedText({
    Key key,
    @required this.text,
    this.fontSize = 15,
    this.strokeWidth = 1,
    this.strokeColor = Colors.black,
    this.textColor = Colors.white,
  }) : super(key: key);

  final String text;
  final double fontSize;
  final double strokeWidth;
  final Color strokeColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
          ),
        )
      ],
    );
  }
}
