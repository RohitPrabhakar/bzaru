import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/helper/size_configs.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/ui/pages/auth/register/register.dart';
import 'package:flutter_bzaru/ui/pages/auth/login/login_bottom_sheet.dart';
import 'package:flutter_bzaru/ui/pages/common/intro/widgets/intro_carousel.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:flutter_bzaru/ui/theme/extensions.dart';

class IntroScreen extends StatefulWidget {
  static CupertinoPageRoute getRoute() {
    return CupertinoPageRoute(builder: (_) => IntroScreen());
  }

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildLoginAndStartedButton(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: BFlatButton(
                text: locale.getTranslatedValue(KeyConstants.login),
                onPressed: () async {
                  await showModalBottomSheet(
                    context: context,
                    builder: (context) => LoginBottomSheet(
                      scaffoldKey: scaffoldKey,
                    ),
                    isScrollControlled: true,
                  );
                },
                // isWraped: true,
                isBold: true,
                color: KColors.primaryDarkColor,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: BFlatButton(
                text: locale.getTranslatedValue(KeyConstants.getStarted),
                // isWraped: true,
                isBold: true,
                onPressed: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => RegisterScreen()));
                },
              ),
            ),
          ],
        ).pH(20),
        SizedBox(height: 10),
        BText(
          locale.getTranslatedValue(KeyConstants.openBusinessLater),
          variant: TypographyVariant.h2,
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    sizeConfig.init(context);

    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Container(
          height: sizeConfig.safeHeight * 105,
          width: sizeConfig.safeWidth * 100,
          child: Column(
            children: [
              SizedBox(height: sizeConfig.safeHeight * 10),
              AppIcon(),
              SizedBox(height: sizeConfig.safeHeight * 2),
              Flexible(
                fit: FlexFit.loose,
                flex: 5,
                child: IntroCarousel(),
              ),
              Flexible(
                fit: FlexFit.loose,
                // flex: 1,
                child: _buildLoginAndStartedButton(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
