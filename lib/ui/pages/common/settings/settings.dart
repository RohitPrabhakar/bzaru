import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/app.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/locale/language_constants.dart';
import 'package:flutter_bzaru/model/dashboard_tiles_model.dart';
import 'package:flutter_bzaru/providers/business/m_customer_state.dart';
import 'package:flutter_bzaru/providers/business/m_order_state.dart';
import 'package:flutter_bzaru/providers/business/product_provider.dart';
import 'package:flutter_bzaru/providers/customer/c_order_state.dart';
import 'package:flutter_bzaru/providers/customer/c_store_state.dart';
import 'package:flutter_bzaru/providers/customer/c_time_state.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/providers/providers.dart';
import 'package:flutter_bzaru/ui/pages/business/b-notifs/b_notifications.dart';
import 'package:flutter_bzaru/ui/pages/business/delivery/delivery_setting.dart';
import 'package:flutter_bzaru/ui/pages/business/help/b_help.dart';
import 'package:flutter_bzaru/ui/pages/business/invite/m_invite.dart';
import 'package:flutter_bzaru/ui/pages/common/common_pages.dart';
import 'package:flutter_bzaru/ui/pages/common/languages/languages_screen.dart';
import 'package:flutter_bzaru/ui/pages/common/view-profile/view_business_profile.dart';
import 'package:flutter_bzaru/ui/pages/common/view-profile/view_personal_profile.dart';
import 'package:flutter_bzaru/ui/pages/personal/account-settings/c_account_settings.dart';
import 'package:flutter_bzaru/ui/pages/personal/c-notifs/c_notification.dart';
import 'package:flutter_bzaru/ui/pages/personal/help/c_help.dart';
import 'package:flutter_bzaru/ui/pages/personal/invite/c_invite.dart';
import 'package:flutter_bzaru/ui/pages/personal/orders/all-orders/c_orders.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_list_tile.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  List<DashboardTilesModel> _businessSettingsTile = [];
  List<DashboardTilesModel> _customerSettingsTile = [];
  String langCode = "en";
  ValueNotifier<bool> _loggignOut = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _loggignOut.dispose();
    super.dispose();
  }

  getSettingsModels() async {
    final locale = AppLocalizations.of(context);

    ///`Setting Screen` Tiles List
    _businessSettingsTile = [
      DashboardTilesModel(
        title: locale.getTranslatedValue(KeyConstants.profile),
        icon: Icons.account_circle,
        nextScreen: null,
        id: "profile",
      ),
      DashboardTilesModel(
        title: locale.getTranslatedValue(KeyConstants.delivery),
        icon: Icons.shopping_cart_outlined,
        nextScreen: DeliverySetting(),
        id: "delivery",
      ),
      DashboardTilesModel(
        title: locale.getTranslatedValue(KeyConstants.notifications),
        icon: Icons.notifications_paused,
        nextScreen: null,
        id: "notifications",
      ),
      DashboardTilesModel(
        title: locale.getTranslatedValue(KeyConstants.inviteOthers),
        icon: Icons.person_add,
        nextScreen: MInvite(),
        id: "invite",
      ),
      DashboardTilesModel(
        title: locale.getTranslatedValue(KeyConstants.termsConditions),
        icon: Icons.event_note,
        nextScreen: null,
        id: "terms",
      ),
      DashboardTilesModel(
        title: locale.getTranslatedValue(KeyConstants.helpAndContact),
        icon: Icons.live_help,
        nextScreen: BHelp(),
        id: "contact",
      ),
      DashboardTilesModel(
        title: locale.getTranslatedValue(KeyConstants.languages),
        icon: Icons.language,
        nextScreen: LanguagesScreen(),
        id: "lang",
      ),
      DashboardTilesModel(
        title: locale.getTranslatedValue(KeyConstants.logOut),
        icon: Icons.exit_to_app,
        nextScreen: null,
        id: "logout",
      ),
    ];

    _customerSettingsTile = [
      DashboardTilesModel(
        title: locale.getTranslatedValue(KeyConstants.profile),
        icon: Icons.account_circle,
        nextScreen: null,
        id: "profile",
      ),
      DashboardTilesModel(
        title: locale.getTranslatedValue(KeyConstants.myOrders),
        icon: Icons.shopping_cart,
        nextScreen: COrders(),
        id: "orders",
      ),
      DashboardTilesModel(
        title: locale.getTranslatedValue(KeyConstants.notifications),
        icon: Icons.notifications_paused,
        nextScreen: CustomerNotifications(),
        id: "notifications",
      ),
      DashboardTilesModel(
        title: locale.getTranslatedValue(KeyConstants.inviteFriends),
        icon: Icons.person_add,
        nextScreen: CInvite(),
        id: "invite",
      ),
      DashboardTilesModel(
        title: locale.getTranslatedValue(KeyConstants.help),
        icon: Icons.help,
        nextScreen: CHelp(),
        id: "help",
      ),
      DashboardTilesModel(
        title: locale.getTranslatedValue(KeyConstants.languages),
        icon: Icons.language,
        nextScreen: LanguagesScreen(),
        id: "lang",
      ),
      DashboardTilesModel(
        title: locale.getTranslatedValue(KeyConstants.logOut),
        icon: Icons.exit_to_app,
        nextScreen: null,
        id: "logout",
      ),
    ];
  }

  ///`Business settings functions`
  Function onBusinessTapFunctions(BuildContext context, String checkId) {
    switch (checkId) {
      case "profile":
        return () async {
          final state = Provider.of<ProfileState>(context, listen: false);
          if (state.customerProfileModel == null) {
            await state.getCustomerProfile();
          }
          if (state.selectedProfile == UserRole.CUSTOMER) {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => ViewPersonalProfile()));
          } else {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => ViewBusinessProfile()));
          }
        };
      case "notifications":
        return () {
          Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (contex) => BusinessNotifications(),
              ));
        };
        break;
      case "terms":
        return () async {
          await launcPrivacy();
        };
        break;
      case "contact":
        return () async {};
        break;
      case "logout":
        return () async {
          showLogoutDailog(context);
        };
        break;
      default:
        return () {};
    }
  }

  ///`Personal Settings functions`
  Function onCustomerTapFunctions(BuildContext context, String checkId) {
    switch (checkId) {
      case "profile":
        return () async {
          final state = Provider.of<ProfileState>(context, listen: false);
          if (state.customerProfileModel == null) {
            await state.getCustomerProfile();
          }
          if (state.selectedProfile == UserRole.CUSTOMER) {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => ViewPersonalProfile()));
          } else {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => ViewBusinessProfile()));
          }
        };
      case "orders":
        return () {};
        break;
      case "logout":
        return () async {
          showLogoutDailog(context);
        };
        break;
      default:
        return () {};
    }
  }

  Future<void> launcPrivacy() async {
    final state = Provider.of<AuthState>(context, listen: false);
    try {
      await state.launchPrivacy();
    } catch (e) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Consumer<ProfileState>(
      builder: (context, state, child) {
        getSettingsModels();
        return state.selectedProfile == UserRole.MERCHANT
            ? Scaffold(
                backgroundColor: Colors.white,
                appBar: BAppBar(
                  title: locale.getTranslatedValue(KeyConstants.settings),
                  removeLeadingIcon: true,
                ),
                body: Container(
                  padding: EdgeInsets.symmetric(vertical: 2.0),
                  child: Column(
                    children: _businessSettingsTile
                        .map(
                          (model) => Column(
                            children: [
                              Container(
                                // color: Colors.white,
                                color: Colors.grey[100],
                                child: BListTile(
                                  leadingIcon: model.icon,
                                  title: model.title,
                                  nextScreen: model.nextScreen ?? null,
                                  onTap:
                                      onBusinessTapFunctions(context, model.id),
                                ),
                              ),
                              SizedBox(height: 2.0),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              )
            : Scaffold(
                backgroundColor: Colors.white,
                appBar: BAppBar(
                  title: locale.getTranslatedValue(KeyConstants.settings),
                  removeLeadingIcon: true,
                ),
                body: Container(
                  padding: EdgeInsets.symmetric(vertical: 2.0),
                  child: Column(
                    children: _customerSettingsTile
                        .map(
                          (model) => Column(
                            children: [
                              Container(
                                // color: Colors.white,
                                color: Colors.grey[100],
                                child: BListTile(
                                  leadingIcon: model.icon,
                                  title: model.title,
                                  nextScreen: model.nextScreen ?? null,
                                  onTap:
                                      onCustomerTapFunctions(context, model.id),
                                ),
                              ),
                              SizedBox(height: 2.0),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              );
      },
    );
  }

  Future<void> showLogoutDailog(BuildContext context) async {
    final locale = AppLocalizations.of(context);
    final profileState = Provider.of<ProfileState>(context, listen: false);

    final customerProfile = profileState.customerProfileModel;
    final merchantProfile = profileState.merchantProfileModel;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: BText(
          locale.getTranslatedValue(KeyConstants.areYouSureLogout),
          variant: TypographyVariant.h2,
        ),
        actions: [
          Row(
            children: [
              BFlatButton2(
                text: locale.getTranslatedValue(KeyConstants.yes),
                onPressed: () async {
                  _loggignOut.value = true;
                  await profileState.updateProfile(customerProfile.copyWith(
                      lastLogout: DateTime.now().toString()));
                  if (merchantProfile != null) {
                    await profileState.updateProfile(merchantProfile.copyWith(
                        lastLogout: DateTime.now().toString()));
                  }

                  Provider.of<COrderState>(context, listen: false).clearState();
                  Provider.of<CTimeState>(context, listen: false).clearState();
                  Provider.of<CStoreState>(context, listen: false).clearState();
                  Provider.of<MCustomerState>(context, listen: false)
                      .clearState();
                  Provider.of<MOrderState>(context, listen: false).clearState();
                  Provider.of<ProductProvider>(context, listen: false)
                      .clearState();
                  profileState.clearTimingHours();
                  final repo =
                      await GetIt.instance<SharedPrefrenceHelper>().clearAll();

                  print("LOGOUT :$repo");
                  Navigator.pushReplacement(context, IntroScreen.getRoute());
                  _loggignOut.value = false;
                },
                isWraped: true,
                buttonColor: Theme.of(context).primaryColor,
                isLoading: _loggignOut,
                padding: EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
              ),
              SizedBox(width: 20),
              BFlatButton2(
                text: locale.getTranslatedValue(KeyConstants.no),
                onPressed: () => Navigator.of(context).pop(),
                isWraped: true,
                buttonColor: Theme.of(context).primaryColor,
                isLoading: _loggignOut,
                padding: EdgeInsets.symmetric(horizontal: 10.0),
              ),
            ],
          )
        ],
      ),
    );
  }
}
