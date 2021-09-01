import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/providers/business/m_customer_state.dart';
import 'package:flutter_bzaru/providers/customer/c_order_state.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class CustomerNotificationTile extends StatefulWidget {
  final OrdersModel ordersModel;

  const CustomerNotificationTile({
    Key key,
    this.ordersModel,
  }) : super(key: key);

  @override
  _CustomerNotificationTileState createState() =>
      _CustomerNotificationTileState();
}

class _CustomerNotificationTileState extends State<CustomerNotificationTile> {
  String notifTime;
  String notifTimeType;

  void calculateTime() {
    final locale = AppLocalizations.of(context);

    final Duration diff = DateTime.now().difference(
        widget.ordersModel.updatedOn ??
            DateTime.now().subtract(Duration(days: 1)));

    final int days = diff.inDays;
    final int hours = diff.inHours;
    final int mins = diff.inMinutes;

    if (days > 0) {
      notifTime = days.toString();
      notifTimeType = locale.getTranslatedValue(KeyConstants.days);
    } else {
      if (hours > 0) {
        notifTime = hours.toString();
        notifTimeType = locale.getTranslatedValue(KeyConstants.hours);
      } else {
        notifTime = mins.toString();
        notifTimeType = locale.getTranslatedValue(KeyConstants.minutes);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    calculateTime();
    final locale = AppLocalizations.of(context);
    final orderStatus = locale
        .getTranslatedValue(
            widget.ordersModel.orderStatus.asString().toLowerCase())
        .capitalize();
    final Duration diff = DateTime.now().difference(
        widget.ordersModel.updatedOn ??
            DateTime.now().subtract(Duration(days: 1)));

    bool isNew = diff.inMinutes < 2 ? true : false;

    return Dismissible(
      key: UniqueKey(),
      onDismissed: (direction) async {
        final state = Provider.of<COrderState>(context, listen: false);
        final len = state.allCustomerNotifications.length;
        SharedPrefrenceHelper().setCustomerNotifLen(len - 1);
        state.removeNotificationsFromDisplay(widget.ordersModel, false);
        state.clearCustomerNotifications(false, widget.ordersModel.orderNumber);
      },
      background: Container(color: KColors.customerPrimaryColor),
      direction: DismissDirection.endToStart,
      child: Container(
        color: KColors.bgColor,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        margin: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: customNetworkImage(
                widget.ordersModel.merchantImage,
                fit: BoxFit.cover,
                placeholder: BPlaceHolder(height: 50, width: 50),
                height: 50,
                width: 50,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BText(
                    widget.ordersModel.merchantName ??
                        locale.getTranslatedValue(KeyConstants.merchantName),
                    variant: TypographyVariant.titleSmall,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BText(
                        locale.getTranslatedValue(KeyConstants.orderStatus),
                        variant: TypographyVariant.h1,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.8,
                        ),
                      ),
                      BText(
                        widget.ordersModel.orderStatus == OrderStatus.PLACED &&
                                isNew
                            ? locale.getTranslatedValue(KeyConstants.newText)
                            : orderStatus,
                        variant: TypographyVariant.h1,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  BText(
                    "$notifTime $notifTimeType ${locale.getTranslatedValue(KeyConstants.ago)}",
                    // "30 ehehhe ago",
                    variant: TypographyVariant.h2,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
