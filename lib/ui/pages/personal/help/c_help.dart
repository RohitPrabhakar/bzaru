import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/auth_provider.dart';
import 'package:flutter_bzaru/ui/pages/personal/help/c_get_help.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class CHelp extends StatefulWidget {
  @override
  _CHelpState createState() => _CHelpState();
}

class _CHelpState extends State<CHelp> {
  Future<void> launcPrivacy() async {
    final state = Provider.of<AuthState>(context, listen: false);
    try {
      await state.launchPrivacy();
    } catch (e) {
      Utility.displaySnackbar(context, msg: e.toString());
    }
  }

  Widget _buildTermsConditions(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Row(
      children: [
        Icon(
          Icons.account_balance,
          size: 30,
          color: KColors.customerPrimaryColor,
        ),
        SizedBox(width: 10),
        Expanded(
          child: BText(
            locale.getTranslatedValue(KeyConstants.termsConditions),
            variant: TypographyVariant.titleSmall,
            style: TextStyle(
              fontWeight: FontWeight.w400,
            ),
          ).ripple(() {
            launcPrivacy();
          }),
        ),
      ],
    );
  }

  Widget _buildNeedHelp(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BText(
          locale.getTranslatedValue(KeyConstants.needToGetInTouch),
          variant: TypographyVariant.h1,
        ),
        SizedBox(height: 2.0),
        BText(
          locale.getTranslatedValue(KeyConstants.careTeam),
          variant: TypographyVariant.h2,
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 15,
          ),
        ),
        SizedBox(height: 10.0),
        _buildButton(context),
        SizedBox(height: 30.0),
        BText(
          locale.getTranslatedValue(KeyConstants.areYouSenior),
          variant: TypographyVariant.h1,
        ),
        SizedBox(height: 2.0),
        BText(
          locale.getTranslatedValue(KeyConstants.contactDedicated),
          variant: TypographyVariant.h2,
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 15,
          ),
        ),
        SizedBox(height: 10.0),
        Row(
          children: [
            Icon(Icons.phone, color: KColors.customerPrimaryColor, size: 23),
            SizedBox(width: 5.0),
            BText(
              "1.844.981.3433",
              variant: TypographyVariant.h1,
            ),
          ],
        ),
        SizedBox(height: 5.0),
        BText(
          "${locale.getTranslatedValue(KeyConstants.daily)}: 8am - 11pm",
          variant: TypographyVariant.h2,
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return BFlatButton(
      text: locale.getTranslatedValue(KeyConstants.getHelp),
      color: KColors.customerPrimaryColor,
      isBold: true,
      isWraped: true,
      padding: EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5.0,
      ),
      onPressed: () {
        Navigator.push(
            context, CupertinoPageRoute(builder: (context) => CGetHelp()));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.helpCenter),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          _buildTermsConditions(context),
          SizedBox(height: 40),
          _buildNeedHelp(context),
        ],
      ).pH(20),
    );
  }
}
