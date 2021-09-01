import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/ui/pages/splash.dart';

class Routes {
  Routes._internal();
  static dynamic route() {
    return {
      '/': (BuildContext context) => SplashPage(),
    };
  }

  static Route onGenerateRoute(RouteSettings settings) {
    final List<String> pathElements = settings.name.split('/');
    if (pathElements[0] != '' || pathElements.length == 1) {
      return null;
    }
    switch (pathElements[1]) {
      case "login":
        return CupertinoPageRoute<bool>(
          builder: (BuildContext context) => SplashPage(),
        );
        break;

      default:
        return onUnknownRoute(
          RouteSettings(name: 'Feature'),
        );
    }
  }

  static Route onUnknownRoute(RouteSettings settings) {
    return CupertinoPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text(settings.name),
          centerTitle: true,
        ),
        body: Center(
          child: Text('${settings.name.split('/')[1]} Comming soon..'),
        ),
      ),
    );
  }
}
