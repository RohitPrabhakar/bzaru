import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bzaru/helper/images.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_app_bar.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:flutter_share_me/flutter_share_me.dart';
import 'package:flutter_bzaru/helper/constants.dart';
import 'package:flutter_bzaru/ui/pages/common/find-contacts/find_contacts.dart';
import 'package:social_share/social_share.dart';

const iOSLocalizedLabels = false;

class MInvite extends StatefulWidget {
  @override
  _MInviteState createState() => _MInviteState();
}

class _MInviteState extends State<MInvite> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  Future<void> _askPermissions() async {
    final locale = AppLocalizations.of(context);
    PermissionStatus permissionStatus = await _getPermission();
    if (permissionStatus == PermissionStatus.granted) {
      Navigator.of(context)
          .push(CupertinoPageRoute(builder: (context) => FindContactsPage()));
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
                title: Text(
                    locale.getTranslatedValue(KeyConstants.permissionsError)),
                content: Text(
                  '${locale.getTranslatedValue(KeyConstants.enableContactAccess)}'
                  '${locale.getTranslatedValue(KeyConstants.inSettings)}',
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: Text(locale.getTranslatedValue(KeyConstants.ok)),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ));
    }
  }

  Future<PermissionStatus> _getPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts];
    } else {
      return permission;
    }
  }

  void share() async {
    final String url = Constants.appLink;

    final String subject = "Bzaru App Link";
    final RenderBox box = context.findRenderObject();

    try {
      await Share.share(
        url,
        subject: subject,
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      Utility.displaySnackbar(context, msg: e.toString(), key: _scaffoldKey);
    }
  }

  void shareToWhatsApp() async {
    final String url = Constants.appLink;
    try {
      await SocialShare.shareWhatsapp(url);
    } catch (e) {
      Utility.displaySnackbar(context, msg: e.toString(), key: _scaffoldKey);
    }
  }

  void shareToFacebook() async {
    final String url = Constants.appLink;
    final isAndroid = Platform.isAndroid;

    try {
      await SocialShare.shareFacebookStory("", "#ffffff", "#000000", url,
              appId: "452921252769470")
          .onError(
        (error, stackTrace) async =>
            isAndroid ? await FlutterShareMe().shareToFacebook(msg: url) : null,
      );
    } catch (e) {
      Utility.displaySnackbar(context, msg: e.toString(), key: _scaffoldKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.inviteCustomers),
        bgColor: KColors.businessPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              children: [
                SizedBox(height: 30),
                Image.asset(
                  KImages.inviteImage,
                  height: 140,
                  color: KColors.businessPrimaryColor,
                ),
                SizedBox(height: 30),
                BText(
                  locale.getTranslatedValue(KeyConstants.inviteYourContacts),
                  variant: TypographyVariant.title,
                  style: TextStyle(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 30),
                BText(
                  locale.getTranslatedValue(KeyConstants.expandYourBusiness),
                  variant: TypographyVariant.h2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 5),
                BText(
                  locale.getTranslatedValue(KeyConstants.sendInviteToCustomer),
                  variant: TypographyVariant.h2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 30),
                BFlatButton(
                  text: locale.getTranslatedValue(KeyConstants.findContacts),
                  onPressed: _askPermissions,
                  color: KColors.businessPrimaryColor,
                  isWraped: true,
                  padding: EdgeInsets.symmetric(horizontal: 70),
                ),
              ],
            ),
            SizedBox(height: 30),
            BText(
              locale.getTranslatedValue(KeyConstants.shareYourLink),
              variant: TypographyVariant.h2,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildShareRow(
                  KImages.whatsappIcon,
                  locale.getTranslatedValue(KeyConstants.share),
                  shareToWhatsApp,
                ),
                _buildShareRow(
                  KImages.fbIcon,
                  locale.getTranslatedValue(KeyConstants.share),
                  shareToFacebook,
                ),
                _buildShareRow(
                  KImages.moreIcon,
                  locale.getTranslatedValue(KeyConstants.share),
                  share,
                ),
              ],
            )
          ],
        ),
      ).pH(20),
    );
  }

  Widget _buildShareRow(String image, String text, Function onTap) {
    return GestureDetector(
      onTap: () async {
        await onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: KColors.primaryDarkColor),
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Row(
          children: [
            Image.asset(
              image,
              height: 23,
              width: 23,
            ),
            SizedBox(width: 10),
            BText(text, variant: TypographyVariant.h2),
          ],
        ),
      ),
    );
  }
}
