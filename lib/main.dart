import 'package:flutter/material.dart';
import 'package:skinai/pages/welcome.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkinAI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
