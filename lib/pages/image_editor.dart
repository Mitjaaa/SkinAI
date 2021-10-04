import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:image/image.dart' as img;

import 'package:skinai/classification/classifier.dart';
import 'package:skinai/classification/classifier_quant.dart';
import 'package:skinai/extended_image/extended_image.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skinai/utils/crop_editor_helper.dart';
import 'package:skinai/widget/common_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ImageEditor extends StatefulWidget {
  final File image;
  final Function callback;
  
  ImageEditor({required File image, required Function callback})
      : this.image = image,
        this.callback = callback;
  
  @override
  _ImageEditorState createState() => _ImageEditorState();
}

class _ImageEditorState extends State<ImageEditor> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
  GlobalKey<ExtendedImageEditorState>();
  final GlobalKey<PopupMenuButtonState<EditorCropLayerPainter>> popupMenuKey =
  GlobalKey<PopupMenuButtonState<EditorCropLayerPainter>>();
  final List<AspectRatioItem> _aspectRatios = <AspectRatioItem>[
    AspectRatioItem(text: 'custom', value: CropAspectRatios.custom),
    AspectRatioItem(text: 'original', value: CropAspectRatios.original),
    AspectRatioItem(text: '1*1', value: CropAspectRatios.ratio1_1),
    AspectRatioItem(text: '4*3', value: CropAspectRatios.ratio4_3),
    AspectRatioItem(text: '3*4', value: CropAspectRatios.ratio3_4),
    AspectRatioItem(text: '16*9', value: CropAspectRatios.ratio16_9),
    AspectRatioItem(text: '9*16', value: CropAspectRatios.ratio9_16)
  ];
  AspectRatioItem? _aspectRatio;
  bool _cropping = false;

  EditorCropLayerPainter? _cropLayerPainter;

  // tflite
  late Classifier _classifier;


  @override
  void initState() {
    _aspectRatio = _aspectRatios.first;
    _cropLayerPainter = const EditorCropLayerPainter();
    _loadImage();
    _classifier = ClassifierQuant();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SkinAI"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              _cropImage(false);
            },
          ),
        ],
      ),
      body: !_cropping ? Column(children: <Widget>[
        Expanded(
          child: _memoryImage != null
              ? ExtendedImage.memory(
            _memoryImage!,
            fit: BoxFit.contain,
            mode: ExtendedImageMode.editor,
            enableLoadState: true,
            extendedImageEditorKey: editorKey,
            initEditorConfigHandler: (ExtendedImageState? state) {
              return EditorConfig(
                maxScale: 8.0,
                cropRectPadding: const EdgeInsets.all(20.0),
                hitTestSize: 20.0,
                cropLayerPainter: _cropLayerPainter!,
                initCropRectType: InitCropRectType.imageRect,
                cropAspectRatio: _aspectRatio!.value,
              );
            },
            cacheRawData: true,
          )
              : ExtendedImage.asset(
            'assets/image.jpg',
            fit: BoxFit.contain,
            mode: ExtendedImageMode.editor,
            enableLoadState: true,
            extendedImageEditorKey: editorKey,
            initEditorConfigHandler: (ExtendedImageState? state) {
              return EditorConfig(
                maxScale: 8.0,
                cropRectPadding: const EdgeInsets.all(20.0),
                hitTestSize: 20.0,
                cropLayerPainter: _cropLayerPainter!,
                initCropRectType: InitCropRectType.imageRect,
                cropAspectRatio: _aspectRatio!.value,
              );
            },
            cacheRawData: true,
          ),
        )
      ])
      :
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Container(width: 10),
          Text("cropping...")
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        //color: Colors.lightBlue,
        shape: const CircularNotchedRectangle(),
        child: ButtonTheme(
          minWidth: 0.0,
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              FlatButtonWithIcon(
                icon: const Icon(Icons.crop),
                label: const Text(
                  'Crop',
                  style: TextStyle(fontSize: 10.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Column(
                          children: <Widget>[
                            const Expanded(
                              child: SizedBox(),
                            ),
                            SizedBox(
                              height: 100,
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.all(20.0),
                                itemBuilder: (_, int index) {
                                  final AspectRatioItem item =
                                  _aspectRatios[index];
                                  return GestureDetector(
                                    child: AspectRatioWidget(
                                      aspectRatio: item.value,
                                      aspectRatioS: item.text,
                                      isSelected: item == _aspectRatio,
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      setState(() {
                                        _aspectRatio = item;
                                      });
                                    },
                                  );
                                },
                                itemCount: _aspectRatios.length,
                              ),
                            ),
                          ],
                        );
                      });
                },
              ),
              FlatButtonWithIcon(
                icon: const Icon(Icons.flip),
                label: const Text(
                  'Flip',
                  style: TextStyle(fontSize: 10.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  editorKey.currentState!.flip();
                },
              ),
              FlatButtonWithIcon(
                icon: const Icon(Icons.rotate_left),
                label: const Text(
                  'Rotate left',
                  style: TextStyle(fontSize: 10.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  editorKey.currentState!.rotate(right: false);
                },
              ),
              FlatButtonWithIcon(
                icon: const Icon(Icons.rotate_right),
                label: const Text(
                  'Rotate right',
                  style: TextStyle(fontSize: 10.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  editorKey.currentState!.rotate(right: true);
                },
              ),
              FlatButtonWithIcon(
                icon: const Icon(Icons.rounded_corner_sharp),
                label: PopupMenuButton<EditorCropLayerPainter>(
                  key: popupMenuKey,
                  enabled: false,
                  offset: const Offset(100, -150),
                  child: const Text(
                    'Painter',
                    style: TextStyle(fontSize: 10.0),
                  ),
                  initialValue: _cropLayerPainter,
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry<EditorCropLayerPainter>>[
                      PopupMenuItem<EditorCropLayerPainter>(
                        child: Row(
                          children: const <Widget>[
                            Icon(
                              Icons.rounded_corner_sharp,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Default'),
                          ],
                        ),
                        value: const EditorCropLayerPainter(),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem<EditorCropLayerPainter>(
                        child: Row(
                          children: const <Widget>[
                            Icon(
                              Icons.circle,
                              color: Colors.blue,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Custom'),
                          ],
                        ),
                        value: const CustomEditorCropLayerPainter(),
                      ),
                    ];
                  },
                  onSelected: (EditorCropLayerPainter value) {
                    if (_cropLayerPainter != value) {
                      setState(() {
                        if (value is CircleEditorCropLayerPainter) {
                          _aspectRatio = _aspectRatios[2];
                        }
                        _cropLayerPainter = value;
                      });
                    }
                  },
                ),
                textColor: Colors.white,
                onPressed: () {
                  popupMenuKey.currentState!.showButtonMenu();
                },
              ),
              FlatButtonWithIcon(
                icon: const Icon(Icons.restore),
                label: const Text(
                  'Reset',
                  style: TextStyle(fontSize: 10.0),
                ),
                textColor: Colors.white,
                onPressed: () {
                  editorKey.currentState!.reset();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _cropImage(bool useNative) async {
    if (_cropping) {
      return;
    }
    String msg = '';
    try {
      setState(() {
        _cropping = true;
      });
      Uint8List? fileData;

      if (useNative) {
        fileData = await cropImageDataWithNativeLibrary(
            state: editorKey.currentState!);
      } else {
        fileData =
        await cropImageDataWithDartLibrary(state: editorKey.currentState!);
      }

      String filePath = widget.image.path.replaceFirst(".jpg", "-crop.jpg");
      final File image = File(filePath);
      await image.writeAsBytes(fileData!);


      print("------RECOGNITIONS INCOMING------");
      var recognitions = _classifier.predict(img.decodeImage(image.readAsBytesSync())!);
      print(recognitions);
      print("----------------------------------");

      _processScan(recognitions.label, recognitions.score, image);

    } catch (e, stack) {
      msg = 'save failed: $e\n $stack';
      print(msg);
    }

    Navigator.pop(context);
    _cropping = false;
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  _processScan(String label, double confidence, File imgPath) {
    Map<String, double> details = {"benign": confidence * 100.0, "malignant": (1.0 - confidence) * 100.0};

    // make zoom ?
    List<File> images = List.empty(growable: true);
    images.add(imgPath);

    widget.callback(label, label == "benign" ? "Your mole looks fine." : "Please visit a doctor.", details, images);
  }

  Uint8List? _memoryImage;
  Future<void> _loadImage() async {
    _memoryImage = widget.image.readAsBytesSync();
  }

  /*Future<void> initTflite() async {
    String? res = await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
        numThreads: 1, // defaults to 1
        isAsset: true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate: true // defaults to false, set to true to use GPU delegate
    );
  }*/
}

class CustomEditorCropLayerPainter extends EditorCropLayerPainter {
  const CustomEditorCropLayerPainter();
  @override
  void paintCorners(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
    final Paint paint = Paint()
      ..color = painter.cornerColor
      ..style = PaintingStyle.fill;
    final Rect cropRect = painter.cropRect;
    const double radius = 6;
    canvas.drawCircle(Offset(cropRect.left, cropRect.top), radius, paint);
    canvas.drawCircle(Offset(cropRect.right, cropRect.top), radius, paint);
    canvas.drawCircle(Offset(cropRect.left, cropRect.bottom), radius, paint);
    canvas.drawCircle(Offset(cropRect.right, cropRect.bottom), radius, paint);
  }
}

class CircleEditorCropLayerPainter extends EditorCropLayerPainter {
  const CircleEditorCropLayerPainter();

  @override
  void paintCorners(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
    // do nothing
  }

  @override
  void paintMask(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
    final Rect rect = Offset.zero & size;
    final Rect cropRect = painter.cropRect;
    final Color maskColor = painter.maskColor;
    canvas.saveLayer(rect, Paint());
    canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.fill
          ..color = maskColor);
    canvas.drawCircle(cropRect.center, cropRect.width / 2.0,
        Paint()..blendMode = BlendMode.clear);
    canvas.restore();
  }

  @override
  void paintLines(
      Canvas canvas, Size size, ExtendedImageCropLayerPainter painter) {
    final Rect cropRect = painter.cropRect;
    if (painter.pointerDown) {
      canvas.save();
      canvas.clipPath(Path()..addOval(cropRect));
      super.paintLines(canvas, size, painter);
      canvas.restore();
    }
  }
}
