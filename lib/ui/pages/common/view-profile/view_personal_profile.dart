import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/images.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/ui/pages/business/profile/business_profile.dart';
import 'package:flutter_bzaru/ui/pages/common/profile/helper/profile_helpers.dart';
import 'package:flutter_bzaru/ui/pages/personal/invite/c_invite.dart';
import 'package:flutter_bzaru/ui/pages/personal/profile/customer_profile_page.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_app_bar.dart';
import 'package:flutter_bzaru/ui/widgets/profle_switch_tabs.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ViewPersonalProfile extends StatefulWidget {
  const ViewPersonalProfile({Key key, this.profilePath}) : super(key: key);

  final String profilePath;

  @override
  _ViewPersonalProfileState createState() => _ViewPersonalProfileState();
}

class _ViewPersonalProfileState extends State<ViewPersonalProfile> {
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
                value: state.primaryProfile == UserRole.CUSTOMER ?? false,
                activeColor: KColors.customerPrimaryColor,
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

  Widget _buildUserImageAndName() {
    return Consumer<ProfileState>(
      builder: (context, state, child) => Container(
        child: Column(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundImage: state.customerProfileModel?.avatar != null
                  ? CachedNetworkImageProvider(
                      state.customerProfileModel?.avatar,
                    )
                  : AssetImage(KImages.userIcon),
            ),
            SizedBox(height: 10),
            BText(
              state.customerProfileModel.name,
              variant: TypographyVariant.title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.2,
              ),
            )
          ],
        ),
      ),
    );
  }

  ///`Personal  Details`
  Widget _buildPersonalDetails() {
    return Consumer<ProfileState>(
      builder: (context, state, child) {
        final profile = state.customerProfileModel;
        return Column(
          children: [
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
                      profile.contactPrimary,
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
                      profile.email,
                      variant: TypographyVariant.h2,
                      softWrap: true,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  ///`Invite Box`
  Widget _buildInviteBox() {
    final locale = AppLocalizations.of(context);

    return Card(
      color: Colors.white,
      elevation: 10.0,
      shadowColor: Colors.grey[300],
      margin: EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              height: 100,
              width: 120,
              child: Image.asset(
                KImages.welcome,
                fit: BoxFit.contain,
              ),
            ),
            Container(
              color: KColors.customerPrimaryColor,
              alignment: Alignment.center,
              height: 60,
              width: 150,
              child: BText(
                locale.getTranslatedValue(KeyConstants.inviteYourFav),
                variant: TypographyVariant.h2,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ).ripple(() {
              Navigator.push(
                  context, CupertinoPageRoute(builder: (context) => CInvite()));
            })
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ProfileState>(context, listen: false);
    final locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.personalProfile),
        trailingIcon: Icons.edit,
        onTrailingPressed: () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) =>
                      CustomerProfilePage(model: state.customerProfileModel)));
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            _buildUserImageAndName(),
            SizedBox(height: 20),
            ProfileSwitchTabs(),
            ProfileHelper.checkIfMerchant(context)
                ? _buildBusinessRow().pH(20)
                : SizedBox(height: 10),
            SizedBox(height: 10),
            _buildPersonalDetails().pH(20),
            SizedBox(height: 20),
            _buildInviteBox(),
            SizedBox(height: 20),
            ProfileHelper.checkIfMerchant(context)
                ? SizedBox()
                : BFlatButton(
                    text:
                        locale.getTranslatedValue(KeyConstants.openBusinessAcc),
                    isWraped: true,
                    isBold: true,
                    color: KColors.businessDarkColor,
                    onPressed: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => BusinessProfile(
                                model: state.merchantProfileModel),
                          ));
                    }),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
