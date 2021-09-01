import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/ui/theme/app_themes.dart';

class ThemeState with ChangeNotifier {
  ThemeData theme;

  ThemeState(this.theme);

  void setTheme(UserRole userRole) {
    if (userRole == UserRole.MERCHANT) {
      theme = AppThemes.merchantTheme;
    } else {
      theme = AppThemes.customerTheme;
    }

    notifyListeners();
  }
}
