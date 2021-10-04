import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:skinai/pages/scanner.dart';
import 'package:skinai/pages/settings.dart';
import 'package:skinai/widget/pastScan.dart';
import 'package:skinai/widget/scanDetails.dart';
import 'package:skinai/widget/widgetButton.dart';
import 'package:skinai/globals.dart' as globals;

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  int scanCount = 0;
  bool isAlive = true;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 500), (Timer t) => isAlive ? setState((){}) : noSuchMethod);
  }

  @override
  void dispose() {
    isAlive = false;
    super.dispose();
  }

Widget _buildDashboard(BuildContext context) {
    return new Stack(
      children: [
        ListView(
          children: <Widget> [
            Container(
              transform: Matrix4Transform().translate(x: 45, y: 60).matrix4,
              child: Text(
                DateFormat('EEEE, d MMM, yyyy').format(DateTime.now()),
                style: GoogleFonts.ubuntuMono(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                ),
              ),
            ),
            Container(
              transform: Matrix4Transform().translate(x: 45, y: 60).matrix4,
              child: Text(
                "Hey!",
                style: GoogleFonts.ubuntuMono(
                    color: Colors.black54,
                    fontSize: 25,
                    fontWeight: FontWeight.w700
                ),
              ),
            ),
            Container(
              transform: Matrix4Transform().translate(x: 45, y: 70).matrix4,
              child: Text(
                "start scanning your skin",
                style: GoogleFonts.ubuntuMono(
                    color: Colors.black38,
                    fontSize: 20,
                    fontWeight: FontWeight.w500
                ),
              ),
            ),
            SizedBox(
              height: 400,
              child: Stack(
                children: <Widget> [
                  Container(
                    transform: Matrix4Transform().translate(y: 100).matrix4,
                    height: 270,
                    child: CustomButton(
                      title: "Scan",
                      description: "check your skin for diseases",
                      icon: LineAwesomeIcons.search,
                      backgroundIcon: LineAwesomeIcons.search_plus,
                      titleColor: Colors.white,
                      descColor: Colors.white54,
                      iconColor: Colors.white,
                      backgroundIconColor: Colors.blue,
                      color: Colors.blue.shade400,
                      callback: openCamera,
                    ),
                  ),

                  Container(
                    transform: Matrix4Transform().translate(x: 45, y: 330).matrix4,
                    child: Text(
                      "Past scans",
                      style: GoogleFonts.ubuntuMono(
                        color: Colors.black,
                        fontSize: 20,
                        //fontWeight: FontWeight.w700
                      ),
                    ),
                  ),


                ],
              ),
            ),
            Container(
              transform: Matrix4Transform().translate(x: 40).matrix4,
              child: SizedBox(
                  height: (globals.pastScans.length == 0 ? 50 : globals.pastScans.length.toDouble() * 105),
                  width: 500.0,
                  child: globals.pastScans.length > 0
                    ?
                    ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: globals.pastScans.reversed.toList()

                    )
                    :
                    Container(
                      transform: Matrix4Transform().translate(x: 10, y: -20).matrix4,
                      child: Text(
                        "You haven't scanned your skin yet.",
                        style: GoogleFonts.ubuntuMono(
                          color: Colors.black,
                          fontSize: 13,
                          //fontWeight: FontWeight.w700
                        ),
                      )
                    )
              ),
            ),
          ]
        ),
        globals.showScanDetail
            ?
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Stack(
                children: <Widget> [
                  GestureDetector(
                    onTap: () => _switchScanDetails(0),
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.black26,
                      child: SizedBox(
                        child: Container(
                          transform: Matrix4Transform().translate(y: 50).matrix4,
                          height: 700,
                          child: ScanDetails(
                            color: Colors.white,
                            titleColor: Colors.blue.shade400,
                            descColor: Colors.black,
                            detection: globals.pastScans[globals.currentPastScanIndex].title,
                            description: globals.pastScans[globals.currentPastScanIndex].description,
                            date: globals.pastScans[globals.currentPastScanIndex].date,
                            details: globals.pastScans[globals.currentPastScanIndex].scanPercentages,//{0: 0.98, 1: 0.53, 2: 0.03},
                            imagePaths: globals.pastScans[globals.currentPastScanIndex].imgPaths,
                            callback: () => noSuchMethod,
                          ),
                        ),
                      ),
                    )
                  )
                ],
              )
            )
            :
            Container(),

      ],
    );
  }

  Future<void> _showScanDetails(String detection, String description,
      Map<String, double> details, List<File> imgPaths) async {

    globals.pastScans.add(PastScan(title: detection, description: description,
        date: DateFormat('d MMM, yyyy').format(DateTime.now()),
        scanPercentages: details, imgPaths: imgPaths,
        callback: _switchScanDetails));

  }

  void _switchScanDetails(int newIndex) {
    globals.currentPastScanIndex = newIndex;
    globals.showScanDetail = !globals.showScanDetail;
    setState(() {

    });
    print("scan detail now: ${globals.showScanDetail}");
  }


  final iconList = <IconData>[
    LineAwesomeIcons.home,
    LineAwesomeIcons.cog,
  ];

  var _bottomNavIndex = 0; //default index of a first screen

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.blueGrey, Colors.grey.shade300]),
        ),
        child:
        _bottomNavIndex == 0 ?
          _buildDashboard(context)
        :
        SettingsPage()
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade400,
        child: Icon(LineAwesomeIcons.search),
        onPressed: openCamera,
        //params
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeColor: Colors.blue.shade400,
        splashSpeedInMilliseconds: 1,
        activeIndex: _bottomNavIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.verySmoothEdge,
        leftCornerRadius: 32,
        rightCornerRadius: 32,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        //other params
      ),
    );
  }

  void openCamera() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CameraPage(_showScanDetails)
        ));
  }
}
