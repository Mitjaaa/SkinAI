import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_sequence_animation/flutter_sequence_animation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:page_transition/page_transition.dart';
import 'package:skinai/widget/proceedButton.dart';

import 'dashboard.dart';

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late SequenceAnimation welcomeAnimation;

  @override
  void initState() {
    super.initState();
    controller = new AnimationController(vsync: this);

    welcomeAnimation = new SequenceAnimationBuilder().addAnimatable(
        animatable: new Tween<double>(begin: 0.0, end: 1.0),
        from: const Duration(milliseconds: 0000),
        to: const Duration(milliseconds: 2000),
        curve: Curves.ease,
        tag: "opacity-offset-welcome"
    ).addAnimatable(
        animatable: new Tween<double>(begin: 0.0, end: 1.0),
        from: const Duration(milliseconds: 2000),
        to: const Duration(milliseconds: 4000),
        curve: Curves.ease,
        tag: "opacity-skinai"
    ).addAnimatable(
        animatable: new Tween<double>(begin: 0.0, end: 1.0),
        from: const Duration(milliseconds: 4000),
        to: const Duration(milliseconds: 4250),
        curve: Curves.ease,
        tag: "opacity-proceed"
    ).animate(controller);
    
    _playWelcomeAnimation();

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget _buildAnimation(BuildContext context, Widget? child) {
    return ScreenUtilInit(
            designSize: Size(360, 690),
            builder: () => new ListView(
              children: <Widget> [
                Container(
                  transform: Matrix4Transform().translate(x: 0, y: welcomeAnimation["opacity-offset-welcome"].value * 300).matrix4,
                  alignment: Alignment.topCenter,
                  child: new Opacity(
                    opacity: welcomeAnimation["opacity-offset-welcome"].value,
                    child: Text(
                      "Welcome to",
                      style: GoogleFonts.ubuntuMono(
                          color: Colors.white,
                          fontSize: 20,
                          //fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ),
                Container(
                  transform: Matrix4Transform().translate(y: 300).matrix4,
                  alignment: Alignment.topCenter,
                  child: new Opacity(
                    opacity: welcomeAnimation["opacity-skinai"].value,
                    child: Text(
                      "SkinAI",
                      style: GoogleFonts.ubuntuMono(
                          color: Colors.white,
                          fontSize: 50,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ),
                Opacity(
                  opacity: welcomeAnimation["opacity-proceed"].value,
                  child: ProceedButton(onPressed: _changeToNicknamePage,),
                )
              ],
            )
    );
  }

  void _changeToNicknamePage() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: DashboardPage(),
      ),
    );
  }

  Future<Null> _playWelcomeAnimation() async {
    try {
      await controller.forward().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.indigo.shade800, Colors.cyan.shade600]),
        ),
        child: new AnimatedBuilder(
            animation: controller,
            builder: _buildAnimation
        ),
      ),
    );
  }
}


