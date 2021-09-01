import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/images.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';

class BackArrow extends StatelessWidget {
  final Function onPressed;

  const BackArrow({Key key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onPressed != null) {
          onPressed();
        }
        Navigator.of(context).pop();
      },
      child: Container(
        height: 34,
        width: 34,
        padding: EdgeInsets.all(6.0),
        child: Image.asset(
          KImages.backArrow,
        ),
      ),
    );
  }
}
