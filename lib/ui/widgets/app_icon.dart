import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/images.dart';

class AppIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      KImages.appLogo,
      height: 90,
      width: 160,
    );
  }
}
