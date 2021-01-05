import 'package:flutter/material.dart';
import 'package:mydeca_web/utils/theme.dart';

typedef void VoidCallback();

class ButtonFilled extends StatelessWidget {

  final Color color;
  final Widget child;
  final EdgeInsets padding;
  final void Function() onPressed;

  ButtonFilled({this.color, this.child, this.padding, this.onPressed, Key key}): super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Card(
        color: color,
        child: new InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onPressed,
          child: Container(padding: padding, child: Center(child: child)),
        ),
      ),
    );
  }
}
