import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/providers/business/m_order_state.dart';
import 'package:flutter_bzaru/ui/pages/business/chats/widgets/b_chat_screen.dart';

import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class OrderDetailsCard extends StatelessWidget {
  const OrderDetailsCard({Key key, this.ordersModel}) : super(key: key);

  final OrdersModel ordersModel;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    final orderNumber = ordersModel.orderNumber ?? "#number";
    final address = ordersModel.address.capitalize() ??
        "#Address Details here of the Customer";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                BText(
                  locale.getTranslatedValue(KeyConstants.order),
                  variant: TypographyVariant.h1,
                ),
                SizedBox(width: 5.0),
                BText(
                  "#$orderNumber",
                  variant: TypographyVariant.h2,
                ),
              ],
            )
            // BText(
            //   ordersModel.orderMode.asString() ?? "Mode",
            //   variant: TypographyVariant.h2,
            // ),
          ],
        ),
        SizedBox(height: 5.0),
        Row(
          children: [
            BText(
              "${locale.getTranslatedValue(KeyConstants.name)}: ",
              variant: TypographyVariant.h1,
            ),
            BText(
              ordersModel.customerName.capitalize() ??
                  locale.getTranslatedValue(KeyConstants.customerName),
              variant: TypographyVariant.h2,
            ),
          ],
        ),
        SizedBox(height: 5.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BText(
              "${locale.getTranslatedValue(KeyConstants.address)}: ",
              variant: TypographyVariant.h1,
            ),
            Expanded(
              child: BText(
                address,
                variant: TypographyVariant.h1,
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  BText(
                    "${locale.getTranslatedValue(KeyConstants.amount)}: ",
                    variant: TypographyVariant.h1,
                  ),
                  BText(
                    "₹ ${ordersModel.totalAmount.toStringAsFixed(2)}",
                    variant: TypographyVariant.h1,
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  BText(
                    "${locale.getTranslatedValue(KeyConstants.discount)}: ",
                    variant: TypographyVariant.h1,
                  ),
                  BText(
                    "₹ ${ordersModel.discount.toStringAsFixed(2)}",
                    variant: TypographyVariant.h1,
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                BText(
                  "${locale.getTranslatedValue(KeyConstants.totalItems)}: ",
                  variant: TypographyVariant.h1,
                ),
                BText(
                  ordersModel.totalItems.toString(),
                  variant: TypographyVariant.h1,
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
              ],
            ),
            Row(
              children: [
                BIcon(
                  iconData: Icons.phone,
                  color: KColors.businessPrimaryColor,
                  onTap: () async {
                    await Provider.of<MOrderState>(context, listen: false)
                        .launchCaller();
                  },
                ),
                SizedBox(width: 10),
                BIcon(
                  iconData: Icons.chat,
                  color: KColors.businessPrimaryColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      BChatScreen.getRoute(ordersModel, null),
                    ); //Passing null Chat Message Model
                  },
                ),
              ],
            )
          ],
        )
      ],
    );
  }
}
