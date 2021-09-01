import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/providers/theme_state.dart';
import 'package:flutter_bzaru/ui/pages/common/profile/helper/profile_helpers.dart';
import 'package:flutter_bzaru/ui/pages/common/view-profile/view_business_profile.dart';
import 'package:flutter_bzaru/ui/pages/common/view-profile/view_personal_profile.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ProfileSwitchTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Consumer<ProfileState>(
      builder: (context, state, child) {
        final isCustomer = state.selectedProfile == UserRole.CUSTOMER;
        final ifMerchantProfileAvaialble =
            ProfileHelper.checkIfMerchant(context);
        return Row(
          children: [
            ///`Personal Profile`
            Expanded(
              child: GestureDetector(
                onTap: state.selectedProfile == UserRole.CUSTOMER
                    ? null
                    : () {
                        state.setSelectedProfile(UserRole.CUSTOMER);
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => ViewPersonalProfile(),
                          ),
                        );

                        Provider.of<ThemeState>(context, listen: false)
                            .setTheme(UserRole.CUSTOMER);
                      },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isCustomer
                        ? KColors.customerPrimaryColor
                        : Colors.white,
                    border: Border.all(
                      color: KColors.customerPrimaryColor,
                    ),
                  ),
                  child: BText(
                    locale.getTranslatedValue(KeyConstants.personal),
                    variant: TypographyVariant.titleSmall,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isCustomer
                          ? Colors.white
                          : KColors.customerPrimaryColor,
                      // : Colors.black,
                    ),
                  ),
                ),
              ),
            ),

            ///`Business Profile`
            Expanded(
                child: GestureDetector(
              onTap: ifMerchantProfileAvaialble
                  ? state.selectedProfile == UserRole.MERCHANT
                      ? null
                      : () {
                          state.setSelectedProfile(UserRole.MERCHANT);
                          Navigator.pushReplacement(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => ViewBusinessProfile()));

                          Provider.of<ThemeState>(context, listen: false)
                              .setTheme(UserRole.MERCHANT);
                        }
                  : null,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ifMerchantProfileAvaialble
                      ? isCustomer
                          ? Colors.white
                          : KColors.businessPrimaryColor
                      : Colors.grey,
                  border: Border.all(
                    color: ifMerchantProfileAvaialble
                        ? KColors.businessPrimaryColor
                        : Colors.grey,
                  ),
                ),
                child: BText(
                  locale.getTranslatedValue(KeyConstants.business),
                  variant: TypographyVariant.titleSmall,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: ifMerchantProfileAvaialble
                        ? isCustomer
                            ? KColors.businessPrimaryColor
                            : Colors.white
                        : Colors.white,
                  ),
                ),
              ),
            )),
          ],
        );
      },
    );
  }
}
