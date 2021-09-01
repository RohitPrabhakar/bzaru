import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';

class KStyles {
  KStyles._();

  static const TextStyle hintTextStyle = TextStyle(
    fontFamily: "Roboto",
    fontWeight: FontWeight.w300,
    color: Colors.black,
    letterSpacing: 0.2,
    fontSize: 16,
  );

  static const TextStyle fieldTextStyle = TextStyle(
    fontFamily: "Roboto",
    fontWeight: FontWeight.w400,
    color: Colors.black,
    letterSpacing: 0.2,
    fontSize: 16,
  );

  static const TextStyle labelTextStyle = TextStyle(
    color: Colors.black,
    fontFamily: "Roboto",
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  static const TextStyle h2 = TextStyle(
    color: Colors.black,
    height: 1,
    letterSpacing: 0.5,
    fontFamily: "Roboto",
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle h1 = TextStyle(
    color: KColors.customerPrimaryColor,
    height: 1,
    letterSpacing: 0.8,
    fontFamily: "Roboto",
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle otp = TextStyle(
    color: Colors.black,
    fontFamily: "Roboto",
    fontSize: 23,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle boldStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w500,
    fontSize: 16,
    height: 1.0,
    fontFamily: 'Roboto',
  );

  static const TextStyle normalStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    height: 1.0,
    fontFamily: 'Roboto',
  );
}
