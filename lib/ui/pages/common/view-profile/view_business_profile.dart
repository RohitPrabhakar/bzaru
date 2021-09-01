import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/images.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/ui/pages/business/profile/business_profile.dart';
import 'package:flutter_bzaru/ui/pages/business/profile/widget/time_table_display.dart';
import 'package:flutter_bzaru/ui/pages/common/view-profile/widgets/view_profile_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_app_bar.dart';
import 'package:flutter_bzaru/ui/widgets/custom_icon.dart';
import 'package:flutter_bzaru/ui/widgets/custom_text.dart';
import 'package:flutter_bzaru/ui/widgets/profle_switch_tabs.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:provider/provider.dart';

class ViewBusinessProfile extends StatefulWidget {
  @override
  _ViewBusinessProfileState createState() => _ViewBusinessProfileState();
}

class _ViewBusinessProfileState extends State<ViewBusinessProfile> {
  ValueNotifier<bool> _isLoading = ValueNotifier<bool>(true);

  @override
  void initState() {
    getMerchantTimings();
    super.initState();
  }

  @override
  void dispose() {
    _isLoading.dispose();
    super.dispose();
  }

  Future<void> getMerchantTimings() async {
    await Provider.of<ProfileState>(context, listen: false)
        .getMerchantTimings();
    _isLoading.value = false;
  }

  ///Building `Business` Text & `Switch` Button
  Widget _buildBusinessRow() {
    final locale = AppLocalizations.of(context);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              locale.getTranslatedValue(KeyConstants.primaryProfile),
              style: KStyles.h2
                  .copyWith(fontWeight: FontWeight.w500, fontSize: 18),
            ),
            Consumer<ProfileState>(
              builder: (context, state, child) => Switch(
                value: state.primaryProfile == UserRole.MERCHANT ?? false,
                activeColor: KColors.businessPrimaryColor,
                onChanged: (val) {
                  if (state.primaryProfile == UserRole.MERCHANT) {
                    state.setPrimaryProfile(UserRole.CUSTOMER);
                  } else {
                    state.setPrimaryProfile(UserRole.MERCHANT);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBusinessProfileDetails() {
    return ValueListenableBuilder(
      valueListenable: _isLoading,
      builder: (context, value, child) => value
          ? Center(child: CircularProgressIndicator())
          : Consumer<ProfileState>(
              builder: (context, state, child) {
                final profile = state.merchantProfileModel;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BText(
                        profile.description,
                        variant: TypographyVariant.h2,
                      ).pH(20),
                      SizedBox(height: 10),

                      ///`Building the WHITE container area`
                      Container(
                        // color: Colors.white,
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey[400], width: 1.2)),
                        child: Column(
                          children: [
                            /// `Address Row`
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BIcon(
                                  iconData: Icons.domain,
                                  color: KColors.iconColors,
                                  iconSize: 30,
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: BText(
                                      "${profile.address1}, ${profile.address2}, ${profile.city}, ${profile.state} ${profile.pinCode}",
                                      variant: TypographyVariant.h2,
                                      softWrap: true,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                      height: 50,
                                      child: Image.asset(
                                        KImages.map,
                                        fit: BoxFit.cover,
                                      )),
                                )
                              ],
                            ),
                            SizedBox(height: 10),

                            /// `Phone Number Row`
                            Row(
                              children: [
                                BIcon(
                                  iconData: Icons.phone,
                                  color: KColors.iconColors,
                                  iconSize: 30,
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Container(
                                    child: BText(
                                      "+91 ${profile.contactPrimary.substring(3)}",
                                      variant: TypographyVariant.h2,
                                      softWrap: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),

                            ///`Email Row`
                            Row(
                              children: [
                                BIcon(
                                  iconData: Icons.email,
                                  color: KColors.iconColors,
                                  iconSize: 30,
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Container(
                                    child: BText(
                                      profile.businessEmail,
                                      variant: TypographyVariant.h2,
                                      softWrap: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),

                            ///`Timing Display`
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BIcon(
                                  iconData: Icons.schedule,
                                  color: KColors.iconColors,
                                  iconSize: 30,
                                ),
                                SizedBox(width: 20),
                                Expanded(child: TimeTableDisplay())
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ProfileState>(context, listen: false);
    final locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.businessProfile),
        trailingIcon: Icons.edit,
        onTrailingPressed: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) =>
                      BusinessProfile(model: state.merchantProfileModel)));
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ViewBusinessProfileImage(),
            SizedBox(height: 10),
            ProfileSwitchTabs(),
            _buildBusinessRow().pH(20),
            // Divider(
            //     color: Colors.grey[400], thickness: 1.2), //TODO: CHANGE COLOR
            _buildBusinessProfileDetails(),
          ],
        ),
      ),
    );
  }
}
