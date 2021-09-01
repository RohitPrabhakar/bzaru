import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/business/m_customer_state.dart';
import 'package:flutter_bzaru/ui/pages/business/b-notifs/widgets/b_notifications_tile.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/overlay_loading.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class BusinessNotifications extends StatefulWidget {
  @override
  _BusinessNotificationsState createState() => _BusinessNotificationsState();
}

class _BusinessNotificationsState extends State<BusinessNotifications> {
  ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  ///Add Order Status
  @override
  void initState() {
    super.initState();
    getMerchantNotifications();
  }

  ///fetching merchant notifications
  Future<void> getMerchantNotifications() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _isLoading.value = true;
      final state = Provider.of<MCustomerState>(context, listen: false);
      await state.getMerchantNotifications();
      final len = state.allMerchantNotifications.length;
      print("Merchant Notif LEN: $len");
      await SharedPrefrenceHelper().setMerchantNotifLen(len);
      _isLoading.value = false;
    });
  }

  ///Building appbar
  PreferredSizeWidget get buildAppBar {
    final locale = AppLocalizations.of(context);

    return AppBar(
      elevation: 5.0,
      backgroundColor: KColors.businessPrimaryColor,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Container(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BIcon(
              iconData: Icons.arrow_back_ios,
              iconSize: 23,
              color: Colors.white,
              onTap: () {
                if (Navigator.canPop(context)) Navigator.of(context).pop();
              },
            ),
            Container(
              height: 40,
              alignment: Alignment.center,
              child: BText(
                locale.getTranslatedValue(KeyConstants.notifications),
                variant: TypographyVariant.title,
                style: TextStyle(color: Colors.white),
              ),
            ),
            Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                child: BText(
                  locale.getTranslatedValue(KeyConstants.clearAll),
                  variant: TypographyVariant.h1,
                  style: TextStyle(color: Colors.white),
                )).ripple(() async {
              final state = Provider.of<MCustomerState>(context, listen: false);
              _isLoading.value = true;
              await state.clearMerchantNotifications(true, "");
              await SharedPrefrenceHelper().setMerchantNotifLen(0);
              state.removeNotificationsFromDisplay(null, true);
              _isLoading.value = false;
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: buildAppBar,
      body: Consumer<MCustomerState>(
          builder: (context, state, child) => ValueListenableBuilder(
                valueListenable: _isLoading,
                builder: (context, isLoading, _) => isLoading
                    ? OverlayLoading(
                        showLoader: _isLoading,
                        loadingMessage:
                            "${locale.getTranslatedValue(KeyConstants.notifications)}...",
                      )
                    : state.displayMerchantNotifs != null &&
                            state.displayMerchantNotifs.isNotEmpty
                        ? Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: ListView.builder(
                              itemCount: state.displayMerchantNotifs.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return BusinessNotificationTile(
                                  ordersModel:
                                      state.displayMerchantNotifs[index],
                                );
                              },
                            ),
                          )
                        : Center(
                            child: BText(
                              "${locale.getTranslatedValue(KeyConstants.noNewNotification)} :(",
                              variant: TypographyVariant.title,
                            ),
                          ),
              )),
    );
  }
}
