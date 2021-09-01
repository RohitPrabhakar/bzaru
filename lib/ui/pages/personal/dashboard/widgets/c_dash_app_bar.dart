import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/ui/pages/common/view-profile/view_personal_profile.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/widgets/cart_icon.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:provider/provider.dart';

class CDashAppBar extends PreferredSize {
  final String customerName;
  final String customerProfileImage;

  CDashAppBar({this.customerName, this.customerProfileImage});

  @override
  Size get preferredSize => Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.of(context).padding.top;
    final locale = AppLocalizations.of(context);

    return PreferredSize(
      child: Container(
        color: KColors.customerPrimaryColor,
        padding: EdgeInsets.only(top: safeArea),
        height: preferredSize.height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: customNetworkImage(
                customerProfileImage,
                fit: BoxFit.cover,
                placeholder: BPlaceHolder(
                  height: 70,
                  width: 70,
                ),
                height: 70,
                width: 70,
              ),
            ),
            SizedBox(width: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  alignment: Alignment.center,
                  child: BText(
                    customerName,
                    variant: TypographyVariant.title,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                BText(
                  locale.getTranslatedValue(KeyConstants.viewAccount),
                  variant: TypographyVariant.h1,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w300),
                ).ripple(() {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => ViewPersonalProfile()));
                }),
                SizedBox(height: 10),
              ],
            ),
            Spacer(),
            // SizedBox(width: 40),
            CartIcon(
                // color: isShrink ? Colors.black : Colors.white,
                // color: isShrink ? Colors.black : Colors.white,
                // textColor: isShrink ? Colors.white : Colors.black,
                )
          ],
        ).pH(10),
      ),
      preferredSize: preferredSize,
    );
  }
}
