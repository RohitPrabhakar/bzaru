import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bzaru/app.dart';
import 'package:flutter_bzaru/helper/config.dart';
import 'package:flutter_bzaru/helper/configs.dart';
import 'package:flutter_bzaru/locator.dart';
import 'package:flutter_bzaru/ui/pages/splash.dart';
import 'package:timezone/data/latest.dart' as tZ;

void main() async {
  final config = devConfig();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // tZ.initializeTimeZones();

  setUpDependency(config);

  final configuredApp = AppConfig(
    config: config,
    child: BzaruApp(home: SplashPage()),
  );

  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  ).then((_) {
    runZonedGuarded(() {
      runApp(configuredApp);
    }, (error, stackTrace) {
      print('runZonedGuarded: Caught error in my root zone.');
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    });
  });
}
