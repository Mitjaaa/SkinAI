import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:styled_widget/styled_widget.dart';

import 'dart:math' as math;

class CustomButton extends StatefulWidget {
  CustomButton(
      {
        required IconData icon,
        required IconData backgroundIcon,
        required Color titleColor,
        required Color descColor,
        required Color iconColor,
        required Color backgroundIconColor,
        required Color color,
        required String title,
        required String description,
        required VoidCallback callback,
      })
  
      : this.icon = icon,
        this.backgroundIcon = backgroundIcon,
        this.titleColor = titleColor,
        this.descColor = descColor,
        this.iconColor = iconColor,
        this.backgroundIconColor = backgroundIconColor,
        this.backgroundColor = color,
        this.title = title,
        this.description = description,
        this.callback = callback;

  final IconData icon;
  final IconData backgroundIcon;
  
  final Color titleColor;
  final Color descColor;
  final Color iconColor;
  final Color backgroundIconColor;
  final Color backgroundColor;
  
  final String title;
  final String description;

  final VoidCallback callback;

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final customButton = ({required Widget child}) => Styled.widget(child: child)
      .alignment(Alignment.center)
      .borderRadius(all: 15)
      .ripple()
      .backgroundColor(widget.backgroundColor, animate: true)
      .clipRRect(all: 25) // clip ripple
      .borderRadius(all: 25, animate: true)
      .elevation(
        pressed ? 0 : 20,
        borderRadius: BorderRadius.circular(25),
        shadowColor: Color(0x30000000),
      )
      .padding(vertical: 12, left: 60, right: 60, bottom: 100) // margin
      .gestures(
        onTapChange: (tapStatus) => setState(() => pressed = tapStatus),
        onTap: widget.callback
      )
      //.transform(transform: Matrix4Transform().translate(y: 100).matrix4)
      .scale(all: pressed ? 0.95 : 1.0, animate: true)
      .animate(Duration(milliseconds: 150), Curves.easeOut);

    final Widget title = Text(
      widget.title,
      style: GoogleFonts.ubuntuMono(
        color: widget.titleColor,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    );

    final Widget description = Text(
      widget.description,
      textAlign: TextAlign.center,
      style: GoogleFonts.ubuntuMono(
        color: widget.descColor,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );

    return customButton(
      child: Stack(
        children: <Widget> [
          ListView(
              children: <Widget> [
                Container(
                    transform: Matrix4Transform().translate(x: 20, y: 90).matrix4,
                    child: title
                ),
                Container(
                    transform: Matrix4Transform().translate(x: -32, y: 95).matrix4,
                    child: description
                ),
              ]
          ),
          Transform(
            transform: Matrix4Transform().translate(x: 20, y: 20).matrix4,
            child: Icon(
              widget.icon,
              color: widget.iconColor,

            ),
          ),
          Transform(
            transform: Matrix4Transform().translate(x: 315, y: 10).matrix4,
            child: Transform(
              transform: Matrix4.rotationY(math.pi),
              child: Icon(
                widget.backgroundIcon,
                color: widget.backgroundIconColor,
                size: 115,
              ),
            ),
          ),
        ],
      )
    );
  }
}