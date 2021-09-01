import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';

class NoInternet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 20,
            width: double.infinity,
            child: Text(
              "OOPS! No Internet Avaialble",
              textAlign: TextAlign.center,
            ),
          ), //TODO: REPLACE WITH IMAGE HERE
          SizedBox(height: 40),
          Container(
            height: 40,
            width: 60,
            child: Text("Retry"),
            alignment: Alignment.center,
          ).ripple(() async {
            final bool isInternetAvaliable =
                await Utility.hasInternetConnection();

            if (isInternetAvaliable) {
              Navigator.of(context).pop();
            } else {}
          }),
        ],
      ),
    );
  }
}
