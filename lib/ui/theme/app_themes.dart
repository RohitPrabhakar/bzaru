import 'package:flutter/material.dart';

import 'colors.dart';

class AppThemes {
  static ThemeData get customerTheme => ThemeData.light().copyWith(
        primaryColor: KColors.customerPrimaryColor,
        primaryColorLight: KColors.businessDarkColor,
        primaryColorDark: KColors.primaryDarkColor,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.transparent,
      );

  // Merchant Theme
  static ThemeData get merchantTheme => ThemeData.light().copyWith(
        primaryColor: KColors.businessPrimaryColor,
        primaryColorLight: KColors.businessDarkColor,
        primaryColorDark: KColors.primaryDarkColor,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.transparent,
      );
  // Return a scaling factor between 0.0 and 1.0 for screens heights ranging
  // from a fixed short to tall range.
  double contentScale(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    const tall = 896.0;
    const short = 480.0;
    return ((height - short) / (tall - short)).clamp(0.0, 1.0);
  }

  // Return a value between low and high for screens heights ranging
  // from a fixed short to tall range.
  double contentScaleFrom(BuildContext context, double low, double high) {
    return low + contentScale(context) * (high - low);
  }

  static double fullWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double fullHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}
