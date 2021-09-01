import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bzaru/ui/theme/styles.dart';

class OverlayLoading extends StatelessWidget {
  const OverlayLoading({
    Key key,
    @required this.showLoader,
    this.loadingMessage,
    this.bgScreenColor,
  }) : super(key: key);

  final ValueNotifier<bool> showLoader;
  final String loadingMessage;
  final Color bgScreenColor;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: showLoader,
      builder: (context, bool value, _) {
        if (value) {
          log(
            "Start",
            name: "Progress indicator",
          );
        } else {
          log(
            "End",
            name: "Progress indicator",
          );
        }
        return !value
            ? Container()
            : Container(
                alignment: Alignment.center,
                color: bgScreenColor ?? Colors.black54,
                child: Container(
                  height: 160,
                  width: 160,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(),
                      ),
                      SizedBox(height: 20),
                      loadingMessage != null
                          ? Text(
                              loadingMessage,
                              style: KStyles.h2,
                              textAlign: TextAlign.center,
                            )
                          : SizedBox()
                    ],
                  ),
                ),
              );
      },
    );
  }
}
