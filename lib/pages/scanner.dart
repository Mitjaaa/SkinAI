import 'dart:async';
import 'dart:io';

import 'package:camerawesome/camerapreview.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/models/capture_modes.dart';
import 'package:camerawesome/models/flashmodes.dart';
import 'package:camerawesome/models/orientations.dart';
import 'package:camerawesome/models/sensors.dart';
import 'package:camerawesome/picture_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'package:image/image.dart' as imgUtils;
import 'package:skinai/pages/image_editor.dart';


class CameraPage extends StatefulWidget {
  // just for E2E test. if true we create our images names from datetime.
  // Else it's just a name to assert image exists
  late final bool randomPhotoName;
  final Function callback;

  CameraPage(this.callback, {this.randomPhotoName = true});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with TickerProviderStateMixin {
  @override

  // Notifiers
  ValueNotifier<CameraFlashes> _switchFlash = ValueNotifier(CameraFlashes.NONE);
  ValueNotifier<Sensors> _sensor = ValueNotifier(Sensors.BACK);
  ValueNotifier<CaptureModes> _captureMode = ValueNotifier(CaptureModes.PHOTO);
  ValueNotifier<Size> _photoSize = ValueNotifier(Size(0,0));
  ValueNotifier<double> _zoomNotifier = ValueNotifier(0);

  // Controllers
  PictureController _pictureController = new PictureController();

  late AnimationController _takePicAnimationController;
  double _scale = 1.0;
  double _rotation = 1.0;
  Duration _duration = Duration(milliseconds: 100);
  Duration _rotateDuration = Duration(milliseconds: 500);

  late CameraAwesome cam;

  @override
  void initState() {
    super.initState();

    _takePicAnimationController = AnimationController(
      vsync: this,
      duration: _duration,
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
      setState(() {});
    });

    cam = CameraAwesome(
      testMode: false,
      onPermissionsResult: (bool? result) { },
      selectDefaultSize: (List<Size> availableSizes) => Size(1920, 1080),
      onCameraStarted: () { },
      onOrientationChanged: (CameraOrientations? newOrientation) { },
      zoom: _zoomNotifier,
      sensor: _sensor,
      photoSize: _photoSize,
      switchFlashMode: _switchFlash,
      captureMode: _captureMode,
      orientation: DeviceOrientation.portraitUp,
      fitted: true,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _takePicAnimationController.dispose();
  }

  double _previousScale = 0;

  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: <Widget> [
            GestureDetector(
              onScaleStart: (ScaleStartDetails details) {
                _previousScale = _zoomNotifier.value + 1;
              },
              onScaleUpdate: (ScaleUpdateDetails details) {
                double result = _previousScale * details.scale - 1;
                if (result < 1 && result > 0) {
                  _zoomNotifier.value = result;
                }
              },
              child: cam,
            ),
            buildBottomInterface(),
          ]
        )
    );
  }

  Widget buildTopInterface() {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: SizedBox(
          height: 200,
          child: Stack(
            children: []
          )
        )
    );
  }

  Widget buildBottomInterface() {
    _scale = 1 - _takePicAnimationController.value;

    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: SizedBox(
            height: 200,
            child: Stack(
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTapDown: _onTakePicDown,
                      onTapUp: _onTakePicUp,
                      onTapCancel: _onTakePicCancel,
                      child: Container(
                        height: 80,
                        width: 80,
                        child: Transform.scale(
                          scale: _scale,
                          child: CustomPaint(
                            painter: CameraButtonPainter(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _changeCam,
                    child: Container(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 75,
                          alignment: Alignment.center,
                          child: Icon(
                              LineAwesomeIcons.sync_icon,
                              color: Colors.white,
                            ),
                        )
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 75,
                          alignment: Alignment.center,
                          child: Icon(
                            LineAwesomeIcons.arrow_left,
                            color: Colors.white,
                          ),
                        )
                    ),
                  ),
                ]
            )
        )
    );
  }

  _changeCam() {
    if (_sensor.value == Sensors.FRONT) {
      _sensor.value = Sensors.BACK;
    } else {
      _sensor.value = Sensors.FRONT;
    }
  }


  _onTakePicDown(TapDownDetails details) async {
    final Directory extDir = await getTemporaryDirectory();
    final tempDir = await Directory('${extDir.path}/test').create(
        recursive: true);
    final String filePath = '${tempDir.path}/${DateTime
        .now()
        .millisecondsSinceEpoch}.jpg';

    _takePicAnimationController.forward();
    await _pictureController.takePicture(filePath);

    print("----------------------------------");
    print("TAKE PHOTO CALLED");
    final file = File(filePath);
    print("==> hastakePhoto : ${file.exists()} | path : $filePath");
    final imgUtils.Image img = imgUtils.decodeImage(
        file.readAsBytesSync()) as imgUtils.Image;
    print("==> img.width : ${img.width} | img.height : ${img.height}");

    Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => ImageEditor(image: file, callback: widget.callback,)
    ));
  }

  _onTakePicUp(TapUpDetails details) {
    Future.delayed(_duration, () {
      _takePicAnimationController.reverse();
    });
  }

  _onTakePicCancel() {
    _takePicAnimationController.reverse();
  }
}

class CameraButtonPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    var bgPainter = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    var radius = size.width / 2;
    var center = Offset(size.width / 2, size.height / 2);
    bgPainter.color = Colors.white.withOpacity(.5);
    canvas.drawCircle(center, radius, bgPainter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}