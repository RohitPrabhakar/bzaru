import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/constants.dart';
import 'package:flutter_bzaru/helper/images.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/widgets/custom_app_bar.dart';
import 'package:flutter_bzaru/ui/widgets/custom_button.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCodeGenerator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    final currentProfile =
        Provider.of<ProfileState>(context, listen: false).merchantProfileModel;

    return Scaffold(
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.qrCode),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),
            Align(
              alignment: Alignment.center,
              child: Container(
                height: 440,
                width: 320,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0.0,
                      bottom: 0.0,
                      child: Container(
                        height: 400,
                        width: 320,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(55),
                        child: Container(
                          height: 110,
                          width: 110,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(55)),
                          child: currentProfile.avatar != null
                              ? customNetworkImage(
                                  currentProfile.avatar,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(KImages.userIcon),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 130,
                      child: Container(
                        alignment: Alignment.center,
                        width: 320,
                        child: BText(
                          currentProfile.name ?? "User Name",
                          variant: TypographyVariant.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        height: 200,
                        width: 320,
                        child: QrImage(
                          data: Constants.appLink, //TODO: QR CODE
                          backgroundColor: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            BFlatButton(
              text: locale.getTranslatedValue(KeyConstants.done),
              isWraped: true,
              isBold: true,
              color: KColors.businessPrimaryColor,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
