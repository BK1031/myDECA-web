import 'package:flutter/material.dart';
import 'package:mydeca_web/utils/theme.dart';

typedef void VoidCallback();

class ButtonFlat extends StatelessWidget {

  final Widget child;
  final EdgeInsets padding;
  final void Function() onPressed;

  ButtonFlat({this.child, this.padding, this.onPressed, Key key}): super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Card(
        elevation: 0,
        color: Colors.transparent,
        child: new InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: onPressed,
          child: Container(padding: padding, child: Center(child: child)),
        ),
      ),
    );
  }
}
