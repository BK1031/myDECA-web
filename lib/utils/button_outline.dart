import 'package:flutter/material.dart';
import 'package:mydeca_web/utils/theme.dart';

typedef void VoidCallback();

class ButtonOutline extends StatelessWidget {

  final Color color;
  final Widget child;
  final EdgeInsets padding;
  final void Function() onPressed;

  ButtonOutline({this.color, this.child, this.padding, this.onPressed, Key key}): super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Card(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4), // if you need this
          side: BorderSide(
            color: color,
            width: 2,
          ),
        ),
        child: new InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onPressed,
          child: Container(padding: padding, child: Center(child: child)),
        ),
      ),
    );
  }
}
