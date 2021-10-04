import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:skinai/globals.dart' as globals;

class PastScan extends StatefulWidget {
  PastScan({
    required String title,
    required String description,
    required String date,
    required Map<String, double> scanPercentages,
    required List<File> imgPaths,
    required Function callback,
  })  : this.title = title,
        this.description = description,
        this.date = date,
        this.scanPercentages = scanPercentages,
        this.imgPaths = imgPaths,
        this.callback = callback;

  final String title;
  final String description;
  final String date;
  final Map<String, double> scanPercentages;
  final List<File> imgPaths;
  final Function callback;

  @override
  _PastScanState createState() => _PastScanState();
}

class _PastScanState extends State<PastScan> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    final pastScan = ({required Widget child}) => Styled.widget(child: child)
        //.alignment(Alignment.center)
        .borderRadius(topLeft: 25, bottomLeft: 25)
        .ripple()
        .height(75)
        .width(250)
        .backgroundColor(Colors.white, animate: true)
        .clipRRect(bottomLeft: 25, topLeft: 25) // clip ripple
        .borderRadius(bottomLeft: 25, topLeft: 25, animate: true)
        .elevation(
          10,
          borderRadius: BorderRadius.circular(25),
          shadowColor: Color(0x30000000),
        )
        .padding(vertical: 12, left: 60)
        .gestures(
            onTapChange: (tapStatus) => setState(() => pressed = tapStatus),
            onTap: () {
              Future.delayed(Duration.zero, () async {
                widget.callback(globals.pastScans.indexOf(widget));
              });
            })
        .scale(all: pressed ? 0.95 : 1.0, animate: true)
        .animate(Duration(milliseconds: 0), Curves.easeOut);

    return Row(
      children: <Widget>[
        Text(widget.date,
            style: GoogleFonts.ubuntuMono(
              color: Colors.black54,
              fontSize: 15,
            )),
        pastScan(
          child: Row(
            children: <Widget>[
              Container(width: 20),
              Icon(LineAwesomeIcons.search),
              Container(width: 10),
              SizedBox(
                  height: 37.5,
                  width: 150,
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      Text(widget.title,
                          style: GoogleFonts.ubuntuMono(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          )),
                      Text(widget.description,
                          style: GoogleFonts.ubuntuMono(
                            color: Colors.black45,
                            fontSize: 12,
                          ))
                    ],
                  ))
            ],
          ),
        )
      ],
    );
  }
}
