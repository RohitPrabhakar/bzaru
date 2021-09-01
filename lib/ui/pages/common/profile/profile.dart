import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/ui/pages/business/profile/business_profile.dart';
import 'package:flutter_bzaru/ui/pages/personal/profile/customer_profile_page.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  static CupertinoPageRoute getRoute() {
    return CupertinoPageRoute(builder: (_) => ProfileScreen());
  }

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Consumer<ProfileState>(
      builder: (context, state, child) {
        print("SELECTED PROFILE :${state.selectedProfile}");
        print("PRIMARY PROFILE :${state.primaryProfile}");

        bool isCustomer =
            state.selectedProfile == UserRole.CUSTOMER ? true : false;

        return Scaffold(
          appBar: isCustomer
              ? BAppBar(
                  title:
                      locale.getTranslatedValue(KeyConstants.personalProfile),
                  removeLeadingIcon: true,
                  trailingIcon: Icons.notification_important,
                )
              : BAppBar(
                  title:
                      locale.getTranslatedValue(KeyConstants.businessProfile),
                  removeLeadingIcon: true,
                ),
          body: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: isCustomer
                    ? CustomerProfilePage(model: state.customerProfileModel)
                    : BusinessProfile(model: state.merchantProfileModel),
              ),
              if (state.isBusy)
                Align(
                  child: Center(child: CircularProgressIndicator()),
                )
            ],
          ),
        );
      },
    );
  }
}
