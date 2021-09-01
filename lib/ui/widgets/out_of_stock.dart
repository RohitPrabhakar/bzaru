import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/images.dart';

class OutOfStock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Image.asset(
        KImages.outOfStock,
        height: 30,
        width: 50,
      ),
    );
  }
}
