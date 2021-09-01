import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/app.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/locale/language_constants.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class LanguagesScreen extends StatefulWidget {
  @override
  _LanguagesScreenState createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  ValueNotifier<int> groupValue = ValueNotifier<int>(1);
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    getLangCode();
    Utility.initConnectivity(_connectivity, mounted);
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen(Utility.updateConnectionStatus);

    super.initState();
  }

  @override
  void dispose() {
    groupValue.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> getLangCode() async {
    final languageCode = await SharedPrefrenceHelper().getLanguageCode();
    groupValue.value = languageCode == "hi" ? 2 : 1;
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    print(Utility.connectionCode);

    return Scaffold(
      appBar: BAppBar(title: locale.getTranslatedValue(KeyConstants.languages)),
      body: ValueListenableBuilder(
        valueListenable: isLoading,
        builder: (BuildContext context, bool value, Widget child) {
          return value
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: ValueListenableBuilder<int>(
                    valueListenable: groupValue,
                    builder: (context, gValue, child) => Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Radio(
                              value: 1,
                              groupValue: gValue,
                              onChanged: (value) async {
                                groupValue.value = value;
                                Locale locale = await setLocale(ENGLISH);
                                BzaruApp.setLocale(context, locale);
                              },
                              activeColor: Theme.of(context).primaryColor,
                            ),
                            BText(
                              "English",
                              variant: TypographyVariant.titleSmall,
                              style: TextStyle(
                                color: gValue == 1
                                    ? Theme.of(context).primaryColor
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Radio(
                              value: 2,
                              groupValue: gValue,
                              onChanged: (value) async {
                                groupValue.value = value;
                                Locale locale = await setLocale(HINDI);
                                BzaruApp.setLocale(context, locale);
                              },
                              activeColor: Theme.of(context).primaryColor,
                            ),
                            BText(
                              "हिंदी",
                              variant: TypographyVariant.titleSmall,
                              style: TextStyle(
                                color: gValue == 2
                                    ? Theme.of(context).primaryColor
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
        },
      ),
    );
  }
}
