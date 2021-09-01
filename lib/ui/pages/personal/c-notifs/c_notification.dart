import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/business/m_customer_state.dart';
import 'package:flutter_bzaru/providers/customer/c_order_state.dart';
import 'package:flutter_bzaru/ui/pages/personal/c-notifs/widgets/c_notif_tile.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/overlay_loading.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class CustomerNotifications extends StatefulWidget {
  @override
  _CustomerNotificationsState createState() => _CustomerNotificationsState();
}

class _CustomerNotificationsState extends State<CustomerNotifications> {
  ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  // ///Add Order Status
  // @override
  // void initState() {
  //   getCustomerNotifications();
  //   super.initState();
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCustomerNotifications();
  }

  ///fetching merchant notifications
  Future<void> getCustomerNotifications() async {
    _isLoading.value = true;
    final state = Provider.of<COrderState>(context, listen: false);
    await state.getCustomerNotifications();
    final len = state.allCustomerNotifications.length;
    print("Notif LEN: $len");
    await SharedPrefrenceHelper().setCustomerNotifLen(len);
    _isLoading.value = false;
  }

  ///Building appbar
  PreferredSizeWidget get buildAppBar {
    final locale = AppLocalizations.of(context);

    return AppBar(
      elevation: 5.0,
      backgroundColor: KColors.customerPrimaryColor,
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
              final state = Provider.of<COrderState>(context, listen: false);
              _isLoading.value = true;
              await state.clearCustomerNotifications(true, "");
              await SharedPrefrenceHelper().setCustomerNotifLen(0);
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
      body: Consumer<COrderState>(
          builder: (context, state, child) => ValueListenableBuilder(
                valueListenable: _isLoading,
                builder: (context, isLoading, _) => isLoading
                    ? OverlayLoading(
                        showLoader: _isLoading,
                        loadingMessage:
                            "${locale.getTranslatedValue(KeyConstants.notifications)}...",
                      )
                    : state.displayCustomerNotifs != null &&
                            state.displayCustomerNotifs.isNotEmpty
                        ? Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: ListView.builder(
                              itemCount: state.displayCustomerNotifs.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return CustomerNotificationTile(
                                  ordersModel:
                                      state.displayCustomerNotifs[index],
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
