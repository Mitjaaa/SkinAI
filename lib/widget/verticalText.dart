import 'package:flutter/material.dart';

class VerticalText extends StatefulWidget {
  final String text;
  final double size;
  final Color color;

  const VerticalText({required String text, double size = 38, Color color = Colors.white})
      : this.size = size, this.color = color, this.text = text;
  
  @override
  _VerticalTextState createState() => _VerticalTextState();
}

class _VerticalTextState extends State<VerticalText> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 10),
      child: RotatedBox(
          quarterTurns: -1,
          child: Text(
            widget.text,
            style: TextStyle(
              color: widget.color,
              fontSize: widget.size,
              fontWeight: FontWeight.w900,
            ),
          )),
    );
  }
}
