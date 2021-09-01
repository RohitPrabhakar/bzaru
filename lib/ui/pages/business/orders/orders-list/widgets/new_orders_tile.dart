import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/images.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/providers/business/m_order_state.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/cancel-order/cancel_order_screen.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/edit-order/edit_order_screen.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/order-details/order_details.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class NewOrdersTile extends StatelessWidget {
  final OrdersModel ordersModel;
  final ValueChanged<String> onChangedMsg;
  final ValueChanged<bool> isLoading;

  const NewOrdersTile(
      {Key key, this.ordersModel, this.onChangedMsg, this.isLoading})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    final state = Provider.of<MOrderState>(context, listen: false);
    final localeMode = ordersModel.orderMode.asString();
    final localeStatus = ordersModel.orderStatus.asString();

    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      secondaryActions: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BIcon(
              iconData: Icons.verified,
              color: ordersModel.orderStatus == OrderStatus.PLACED
                  ? KColors.businessPrimaryColor
                  : Colors.grey[400],
              onTap: ordersModel.orderStatus == OrderStatus.PLACED
                  ? () async {
                      isLoading(true);
                      state.setSelectedOrder(ordersModel);
                      onChangedMsg(locale
                          .getTranslatedValue(KeyConstants.acceptingOrder));
                      await state.updateOrderStatus(
                          OrderStatus.ACCEPTED); //UPDATING Status to DB

                      await Future.delayed(Duration.zero, () {
                        state.getOrderStatus();
                      });
                      isLoading(false);
                    }
                  : null,
            ),
            BIcon(
              iconData: Icons.edit,
              color: ordersModel.orderStatus == OrderStatus.PLACED
                  ? KColors.businessPrimaryColor
                  : Colors.grey[400],
              onTap: ordersModel.orderStatus == OrderStatus.PLACED
                  ? () {
                      state.setSelectedOrder(ordersModel);

                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => EditOrderScreen()));
                    }
                  : null,
            ),
            BIcon(
              iconData: Icons.remove_circle,
              color: ordersModel.orderStatus == OrderStatus.PLACED
                  ? KColors.businessPrimaryColor
                  : Colors.grey,
              onTap: ordersModel.orderStatus == OrderStatus.PLACED
                  ? () {
                      state.setSelectedOrder(ordersModel);

                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => CancelOrderScreen()));
                    }
                  : null,
            ),
          ],
        )
      ],
      child: Container(
        // color: Colors.red,
        padding: EdgeInsets.symmetric(horizontal: 30),
        margin: EdgeInsets.symmetric(vertical: 15),
        child: Column(
          children: [
            Row(
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                    child: BText(
                      ordersModel.customerName.capitalize() ?? "Customer Name",
                      variant: TypographyVariant.h1,
                      // style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: BText(
                    "#${ordersModel.orderNumber}" ?? "#OrderNumber",
                    variant: TypographyVariant.h1,
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                )
              ],
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: BText(
                    locale.getTranslatedValue(KeyConstants.totalAmount),
                    variant: TypographyVariant.h1,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BText(
                        ordersModel.totalAmount.toStringAsFixed(2) ?? "amount",
                        variant: TypographyVariant.h1,
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                      ordersModel.orderStatus == OrderStatus.PLACED
                          ? Image.asset(
                              KImages.newOrderImage,
                              height: 30,
                              width: 50,
                              color: KColors.businessPrimaryColor,
                            )
                          : SizedBox(),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "${locale.getTranslatedValue(KeyConstants.mode)}:",
                          style: TextStyle(
                            color: KColors.primaryDarkColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        WidgetSpan(child: SizedBox(width: 5.0)),
                        TextSpan(
                          text: ordersModel.orderMode != null
                              ? locale
                                  .getTranslatedValue(localeMode.toLowerCase())
                                  .capitalize()
                              : locale.getTranslatedValue(KeyConstants.mode),
                          style: TextStyle(
                            color: KColors.primaryDarkColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              "${locale.getTranslatedValue(KeyConstants.status)}:",
                          style: TextStyle(
                            color: KColors.primaryDarkColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        WidgetSpan(child: SizedBox(width: 5.0)),
                        TextSpan(
                          text: localeStatus != null
                              ? locale
                                  .getTranslatedValue(
                                      localeStatus.toLowerCase())
                                  .capitalize()
                              : locale
                                  .getTranslatedValue(ordersModel.orderStatus
                                      .asString()
                                      .toLowerCase())
                                  .capitalize(),
                          // .capitalize(),
                          style: TextStyle(
                            color: KColors.primaryDarkColor,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ).ripple(() {
        Provider.of<MOrderState>(context, listen: false)
            .setSelectedOrder(ordersModel);

        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => OrderDetails(),
            ));
      }),
    );
  }
}
