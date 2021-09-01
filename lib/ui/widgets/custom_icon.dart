import 'package:flutter/material.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';

class BIcon extends StatelessWidget {
  ///`IconData` to identify the type of the [Icon]
  final IconData iconData;

  ///`IconSize` to control the size
  final double iconSize;

  ///`TapSize` is the [Containers] Size with `GestureDetector`
  final double tapSize;

  ///`OnTap` is the actual function to be exceuted when
  ///the user taps.
  final Function onTap;
  final Color color;
  final AlignmentGeometry alignment;

  const BIcon({
    Key key,
    @required this.iconData,
    this.iconSize = 23,
    this.tapSize = 30,
    this.onTap,
    this.color = KColors.customerPrimaryColor,
    this.alignment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: tapSize,
      width: tapSize,
      alignment: alignment ?? Alignment.center,
      child: Icon(
        iconData,
        size: iconSize,
        color: color,
      ),
    ).ripple(onTap ?? () {});
  }
}
