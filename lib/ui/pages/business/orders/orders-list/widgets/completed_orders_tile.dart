import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/providers/business/m_order_state.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/order-details/order_details.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:provider/provider.dart';

class CompletedOrdersTile extends StatelessWidget {
  final OrdersModel ordersModel;

  const CompletedOrdersTile({Key key, this.ordersModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Container(
                  child: BText(
                    ordersModel.customerName ?? "Customer Name",
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: BText(
                  locale.getTranslatedValue(KeyConstants.totalAmount),
                  variant: TypographyVariant.h1,
                ),
              ),
              Expanded(
                child: BText(
                  ordersModel.totalAmount.toStringAsFixed(2) ?? "amount",
                  variant: TypographyVariant.h1,
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
              )
            ],
          ),
          SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            "${locale.getTranslatedValue(KeyConstants.created)}:",
                        style: TextStyle(
                          color: KColors.primaryDarkColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      WidgetSpan(child: SizedBox(width: 5.0)),
                      TextSpan(
                        text: ordersModel.createdAt.toString(),
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
                        text: ordersModel.orderStatus == OrderStatus.CANCEL
                            ? "${locale.getTranslatedValue(KeyConstants.status)}:"
                            : "${locale.getTranslatedValue(KeyConstants.closed)}:",
                        style: TextStyle(
                          color: KColors.primaryDarkColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      WidgetSpan(child: SizedBox(width: 5.0)),
                      TextSpan(
                        text: ordersModel.orderStatus == OrderStatus.CANCEL
                            ? locale.getTranslatedValue(KeyConstants.cancelled)
                            : ordersModel.closedAt.toString(),
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
    });
  }
}
