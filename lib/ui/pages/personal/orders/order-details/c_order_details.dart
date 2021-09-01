import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/order_model.dart';

import 'package:flutter_bzaru/providers/customer/c_order_state.dart';

import 'package:flutter_bzaru/ui/pages/personal/chats/c_chat_screen.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:provider/provider.dart';

class COrderDetails extends StatelessWidget {
  final OrdersModel ordersModel;
  final String langCode;

  const COrderDetails({Key key, this.ordersModel, this.langCode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.orderDetails),
        bgColor: KColors.customerPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildMerchantImage(),
            SizedBox(height: 20),
            _buildCallAndMessage(context),
            SizedBox(height: 40),
            _buildOrderDetails(context),
            SizedBox(height: 40),
          ],
        ),
      ).pH(20),
    );
  }

  Widget _buildMerchantImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: customNetworkImage(
            ordersModel?.merchantImage,
            fit: BoxFit.cover,
            placeholder: BPlaceHolder(
              height: 80,
              width: 80,
            ),
            height: 80,
            width: 80,
          ),
        ),
        SizedBox(height: 5.0),
        BText(
          ordersModel?.merchantName,
          variant: TypographyVariant.titleSmall,
          // style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildOrderDetails(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: BText(
                locale.getTranslatedValue(KeyConstants.orderNumber),
                variant: TypographyVariant.h2,
              ),
            ),
            Flexible(
              child: BText(
                ordersModel?.orderNumber ??
                    locale.getTranslatedValue(KeyConstants.orderNumber),
                variant: TypographyVariant.h2,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: BText(
                locale.getTranslatedValue(KeyConstants.dateOfOrder),
                variant: TypographyVariant.h2,
              ),
            ),
            Flexible(
              child: BText(
                DateFormat("dd-MM-yyyy").format(ordersModel?.createdAt) ??
                    locale.getTranslatedValue(KeyConstants.dateOfOrder),
                variant: TypographyVariant.h2,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: BText(
                locale.getTranslatedValue(KeyConstants.modeOfOrder),
                variant: TypographyVariant.h2,
              ),
            ),
            Flexible(
              child: BText(
                locale
                    .getTranslatedValue(
                        ordersModel.orderMode.asString().toLowerCase())
                    .capitalize(),
                variant: TypographyVariant.h2,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: BText(
                locale.getTranslatedValue(KeyConstants.totalItems),
                variant: TypographyVariant.h2,
              ),
            ),
            Flexible(
              child: BText(
                ordersModel?.totalItems.toString() ??
                    locale.getTranslatedValue(KeyConstants.totalItems),
                variant: TypographyVariant.h2,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BText(
              locale.getTranslatedValue(KeyConstants.items),
              variant: TypographyVariant.h1,
            ),
            SizedBox(height: 5),
            ListView.builder(
              shrinkWrap: true,
              itemCount: ordersModel?.items?.length,
              itemBuilder: (context, index) => Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: BText(
                        "${ordersModel?.items[index]?.title} 1x${ordersModel?.items[index]?.quantity}" ??
                            locale.getTranslatedValue(KeyConstants.itemName),
                        variant: TypographyVariant.h2,
                      ),
                    ),
                    Flexible(
                      child: BText(
                        "₹ ${ordersModel?.items[index]?.price?.toStringAsFixed(2)}" ??
                            locale.getTranslatedValue(KeyConstants.itemName),
                        variant: TypographyVariant.h2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: BText(
                locale.getTranslatedValue(KeyConstants.subTotal),
                variant: TypographyVariant.h1,
              ),
            ),
            Flexible(
              child: BText(
                "₹ ${ordersModel.totalAmount + ordersModel.discount}" ??
                    locale.getTranslatedValue(KeyConstants.subTotal),
                variant: TypographyVariant.h1,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: BText(
                locale.getTranslatedValue(KeyConstants.discount),
                variant: TypographyVariant.h1,
              ),
            ),
            Flexible(
              child: BText(
                "₹ ${ordersModel.discount.toStringAsFixed(2)}" ??
                    locale.getTranslatedValue(KeyConstants.discount),
                variant: TypographyVariant.h1,
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: BText(
                locale.getTranslatedValue(KeyConstants.total),
                variant: TypographyVariant.h1,
              ),
            ),
            Flexible(
              child: BText(
                "₹ ${ordersModel.totalAmount.toStringAsFixed(2)}" ??
                    locale.getTranslatedValue(KeyConstants.total),
                variant: TypographyVariant.h1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCallAndMessage(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        BIcon(
          iconData: Icons.phone,
          color: KColors.customerPrimaryColor,
          onTap: () async {
            await Provider.of<COrderState>(context, listen: false)
                .launchCaller(ordersModel);
          },
        ),
        SizedBox(width: 10),
        BIcon(
          iconData: Icons.chat,
          color: KColors.customerPrimaryColor,
          onTap: () {
            Navigator.push(
              context,
              CChatScreen.getRoute(ordersModel, null),
            ); //Passing null Chat Message Model
          },
        ),
      ],
    );
  }
}
