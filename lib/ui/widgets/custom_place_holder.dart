import 'package:flutter/material.dart';

class BPlaceHolder extends StatelessWidget {
  final double height;
  final double width;

  const BPlaceHolder({Key key, this.height, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 0,
      width: width ?? 0,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        boxShadow: [BoxShadow(color: Colors.grey[300], blurRadius: 5.0)],
      ),
    );
  }
}
