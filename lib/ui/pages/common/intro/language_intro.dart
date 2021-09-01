import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/app.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/helper/size_configs.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/locale/language_constants.dart';
import 'package:flutter_bzaru/ui/pages/common/common_pages.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class LanguageIntroScreen extends StatefulWidget {
  @override
  _LanguageIntroScreenState createState() => _LanguageIntroScreenState();
}

class _LanguageIntroScreenState extends State<LanguageIntroScreen> {
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ValueNotifier<bool> isEnglish = ValueNotifier<bool>(false);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    getLangCode();
    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> getLangCode() async {
    final languageCode = await SharedPrefrenceHelper().getLanguageCode();
    isEnglish.value =
        languageCode == null || languageCode == "en" ? true : false;
    Locale locale = await setLocale(ENGLISH);
    BzaruApp.setLocale(context, locale);
    Utility.initConnectivity(_connectivity, mounted);
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen(Utility.updateConnectionStatus);
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    sizeConfig.init(context);
    final locale = AppLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      body: ValueListenableBuilder(
        valueListenable: isLoading,
        builder: (context, loading, _) => loading
            ? Center(
                child: CircularProgressIndicator(
                backgroundColor: KColors.customerPrimaryColor,
              ))
            : SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: ValueListenableBuilder(
                  valueListenable: isEnglish,
                  builder: (context, english, child) => Container(
                    height: sizeConfig.safeHeight * 110,
                    width: sizeConfig.safeWidth * 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BText(
                          locale.getTranslatedValue(
                                  KeyConstants.pleaseSelectLanguage) ??
                              "Please select your language.",
                          variant: TypographyVariant.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: KColors.customerPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 30),
                        BFlatButton(
                          text: "English",
                          isWraped: true,
                          isBold: true,
                          color: english
                              ? KColors.customerPrimaryColor
                              : Colors.white,
                          textStyle: english
                              ? TextStyle()
                              : TextStyle(color: Colors.black),
                          isColored: true,
                          onPressed: () async {
                            Locale locale = await setLocale(ENGLISH);
                            BzaruApp.setLocale(context, locale);
                            isEnglish.value = true;
                          },
                        ),
                        SizedBox(height: 10),
                        BFlatButton(
                          text: "हिंदी",
                          isWraped: true,
                          isBold: true,
                          color: english
                              ? Colors.white
                              : KColors.customerPrimaryColor,
                          textStyle: english
                              ? TextStyle(color: Colors.black)
                              : TextStyle(),
                          isColored: true,
                          onPressed: () async {
                            Locale locale = await setLocale(HINDI);
                            BzaruApp.setLocale(context, locale);
                            isEnglish.value = false;
                          },
                        ),
                        SizedBox(height: 50),
                        BFlatButton(
                            text: locale.getTranslatedValue(
                                    KeyConstants.nextText) ??
                                "Next",
                            isWraped: true,
                            isBold: true,
                            color: KColors.customerPrimaryColor,
                            padding: EdgeInsets.symmetric(horizontal: 60),
                            onPressed: () {
                              Navigator.push(context, IntroScreen.getRoute());
                            }),
                      ],
                    ).pH(40),
                  ),
                ),
              ),
      ),
    );
  }

  // Widget _buildFlatButton(){
  //   return
  // }
}
