import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/widgets/custom_text.dart';
import 'package:intl/intl.dart';

class Utility {
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<Orientation> getOrientation(BuildContext context) async {
    final orientation = MediaQuery.of(context).orientation;
    return orientation;
  }

  static void displaySnackbar(BuildContext context,
      {String msg = "Feature is under development",
      GlobalKey<ScaffoldState> key}) {
    final snackBar = SnackBar(
      content: Text(msg),
      duration: Duration(seconds: 3),
    );
    if (key != null && key.currentState != null) {
      key.currentState.hideCurrentSnackBar();
      key.currentState.showSnackBar(snackBar);
    } else {
      Scaffold.of(context).hideCurrentSnackBar();
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  static String getChatTime(String date) {
    if (date == null || date.isEmpty) {
      return '';
    }
    String msg = '';
    var dt = DateTime.parse(date).toLocal();

    if (DateTime.now().toLocal().isBefore(dt)) {
      return DateFormat.jm().format(DateTime.parse(date).toLocal()).toString();
    }

    var dur = DateTime.now().toLocal().difference(dt);
    if (dur.inDays > 0) {
      msg = '${dur.inDays} d';
      return dur.inDays == 1 ? '1d' : DateFormat("dd MMM").format(dt);
    } else if (dur.inHours > 0) {
      msg = '${dur.inHours} h';
    } else if (dur.inMinutes > 0) {
      msg = '${dur.inMinutes} m';
    } else if (dur.inSeconds > 0) {
      msg = '${dur.inSeconds} s';
    } else {
      msg = 'now';
    }
    return msg;
  }

  static Future<void> displayImagePicker(BuildContext context,
      Function takePicture, Function galleryPicture) async {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 30),
            BText(
              "Profile Photo",
              variant: TypographyVariant.titleSmall,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Flexible(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: galleryPicture,
                        child: CircleAvatar(
                          radius: 23,
                          backgroundColor: KColors.bgColor,
                          child: Icon(
                            Icons.photo,
                            color: Theme.of(context).primaryColor,
                            size: 23,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      BText(
                        "Gallery",
                        variant: TypographyVariant.h1,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Flexible(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: takePicture,
                        child: CircleAvatar(
                          radius: 23,
                          backgroundColor: KColors.bgColor,
                          child: Icon(
                            Icons.camera,
                            color: Theme.of(context).primaryColor,
                            size: 23,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      BText(
                        "Camera",
                        variant: TypographyVariant.h1,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  static int connectionCode = 1;

  // Platform messages are asynchronous, so we initialize in an async method.
  static Future<void> initConnectivity(
      Connectivity connectivity, bool mounted) async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return updateConnectionStatus(result);
  }

  static Future<void> updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
        connectionCode = 1;
        break;
      case ConnectivityResult.none:
        connectionCode = 0;
        break;
      default:
        connectionCode = 0;
        break;
    }
  }
}
