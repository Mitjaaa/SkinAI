import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class ProceedButton extends StatefulWidget {
  final VoidCallback onPressed;

  ProceedButton({required this.onPressed});

  @override
  _ProceedButtonState createState() => _ProceedButtonState();
}

class _ProceedButtonState extends State<ProceedButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 400, right: 100, left: 100),
      child: Container(
        alignment: Alignment.bottomRight,
        height: 50,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade300,
              blurRadius: 10.0, // has the effect of softening the shadow
              spreadRadius: 1.0, // has the effect of extending the shadow
              offset: Offset(
                5.0, // horizontal, move right 10
                5.0, // vertical, move down 10
              ),
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: TextButton(
          onPressed: widget.onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Proceed',
                style: TextStyle(
                  color: Colors.lightBlue.shade600,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(width: 5,),
              Icon(LineAwesomeIcons.arrow_right)
            ],
          ),
        ),
      ),
    );
  }
}
