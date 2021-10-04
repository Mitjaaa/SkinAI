import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:styled_widget/styled_widget.dart';

import 'dart:math' as math;

class ScanDetails extends StatefulWidget {
  ScanDetails(
      {
        required List<File> imagePaths,
        required Map<String, double> details,
        required String detection,
        required String date,
        required Color titleColor,
        required Color descColor,
        required Color color,
        required String description,
        required VoidCallback callback,
      })

      : this.titleColor = titleColor,
        this.descColor = descColor,
        this.backgroundColor = color,
        this.imagePaths = imagePaths,
        this.details = details,
        this.detection = detection,
        this.date = date,
        this.description = description,
        this.callback = callback;

  final Color titleColor;
  final Color descColor;
  final Color backgroundColor;

  final List<File> imagePaths;
  final Map<String, double> details;

  final String detection;
  final String date;
  final String description;

  final VoidCallback callback;


  @override
  _ScanDetailsState createState() => _ScanDetailsState();
}

class _ScanDetailsState extends State<ScanDetails> {
  bool pressed = false;

  // image carousel variables
  int _current = 0;
  final CarouselController _controller = CarouselController();


  @override
  Widget build(BuildContext context) {
    final scanDetails = ({required Widget child}) => Styled.widget(child: child)
        .alignment(Alignment.center)
        .borderRadius(all: 15)
        .ripple()
        .backgroundColor(widget.backgroundColor, animate: true)
        .clipRRect(all: 25) // clip ripple
        .borderRadius(all: 25, animate: true)
        .padding(vertical: 12, left: 60, right: 60, bottom: 150) // margin
        .gestures()
        .animate(Duration(milliseconds: 150), Curves.easeOut);

    final Widget title = Text(
      "${widget.detection}",
      style: GoogleFonts.ubuntuMono(
        color: widget.titleColor,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    );

    /*final Widget description = Text(
      widget.description,
      textAlign: TextAlign.center,
      style: GoogleFonts.ubuntuMono(
        color: widget.descColor,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );*/

    final Widget details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget> [
        Row(
          children: <Widget> [
            Container(
              width: 100,
              child: Text(
                "detection: ",
                style: GoogleFonts.ubuntuMono(
                  color: widget.descColor,
                  fontSize: 12,
                ),
              ),
            ),
            Container(
              width: 100,
              alignment: Alignment.centerRight,
              child: Text(
                widget.detection,
                style: GoogleFonts.ubuntuMono(
                  color: widget.descColor,
                  fontSize: 12,
                ),
              ),
            )
          ],
        ),
        Container(
          height: 2.5,
        ),
        Row(
          children: <Widget> [
            Container(
              width: 100,
              child: Text(
                "date: ",
                style: GoogleFonts.ubuntuMono(
                  color: widget.descColor,
                  fontSize: 12,
                ),
              ),
            ),
            Container(
              width: 100,
              alignment: Alignment.centerRight,
              child: Text(
                widget.date,
                style: GoogleFonts.ubuntuMono(
                  color: widget.descColor,
                  fontSize: 12,
                ),
              ),
            )
          ],
        ),
        Container(
          height: 10,
        ),
        widget.details.entries.map((entry) =>
            Row(
              children: <Widget> [
                Container(
                  width: 150,
                  child: Text(
                    "detected {${entry.key}}: ",
                    style: GoogleFonts.ubuntuMono(
                      color: widget.descColor.withOpacity(entry.value > 50 ? 1.0 : 0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  width: 50,
                  alignment: Alignment.centerRight,
                  child: Text(
                    "${double.parse(entry.value.toStringAsFixed(2))}% ",
                    style: GoogleFonts.ubuntuMono(
                      color: widget.descColor.withOpacity(entry.value > 50 ? 1.0 : 0.6),
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
          ).toList().toColumn(),
      ]
    );


    final List<Widget> imageSliders = widget.imagePaths
        .map((item) => Container(
            child: Container(
              margin: EdgeInsets.all(5.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Stack(
                    children: <Widget>[
                      Image.file(item, fit: BoxFit.cover, width: 1000.0),
                    ],
                  )),
            ),
          ))
        .toList();

    return scanDetails(
        child: Stack(
          children: <Widget> [
            ListView(
                children: <Widget> [
                  Container(
                    child: CarouselSlider(
                      items: imageSliders,
                      carouselController: _controller,
                      options: CarouselOptions(
                          autoPlay: false,
                          enlargeCenterPage: true,
                          aspectRatio: 4/3,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                              print("index {$_current}");
                            });
                          }),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imageSliders.asMap().entries.map((entry) {
                      return GestureDetector(
                        child: Container(
                          width: 9.0,
                          height: 9.0,
                          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black
                                  .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                        ),
                      );
                    }).toList(),
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 50,
                    child: title,
                  ),
                  Container(height: 10),
                  Container(
                    transform: Matrix4Transform().translate(x: 44).matrix4,
                    alignment: Alignment.centerLeft,
                    child: details,
                  ),
                ]
            ),
          ],
        )
    );
  }
}