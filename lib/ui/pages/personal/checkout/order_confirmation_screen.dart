import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/providers/customer/c_order_state.dart';
import 'package:flutter_bzaru/ui/pages/common/common_pages.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:provider/provider.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final List<OrdersModel> listOfOrders;

  const OrderConfirmationScreen({Key key, this.listOfOrders}) : super(key: key);

  void goToHomePage(BuildContext context) {
    Provider.of<COrderState>(context, listen: false).clearOrderIds();
    Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
            builder: (context) => BottomNavBar(
                  selectedIndex: 0,
                  selectedUserProfile: UserRole.CUSTOMER,
                )),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BAppBar(
        removeLeadingIcon: true,
        elevation: 0.0,
        title: locale.getTranslatedValue(KeyConstants.orderConfirmation),
      ),
      bottomNavigationBar: GestureDetector(
        onTap: () {
          goToHomePage(context);
        },
        child: Container(
          height: 60,
          alignment: Alignment.center,
          color: KColors.customerPrimaryColor,
          child: BText(
            locale.getTranslatedValue(KeyConstants.goToHome),
            variant: TypographyVariant.titleSmall,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: ListView.separated(
        itemCount: listOfOrders.length,
        shrinkWrap: true,
        itemBuilder: (context, index) => OrderConfirmationTile(
          ordersModel: listOfOrders[index],
        ),
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey,
          thickness: 1.5,
        ),
      ),
    );
  }
}

class OrderConfirmationTile extends StatelessWidget {
  final OrdersModel ordersModel;

  const OrderConfirmationTile({Key key, this.ordersModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: _buildOrderDetails(context))
        .pH(20);
  }

  Widget _buildMerchantImage(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Container(
      width: double.maxFinite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: customNetworkImage(
                  ordersModel?.merchantImage,
                  fit: BoxFit.cover,
                  placeholder: BPlaceHolder(
                    height: 50,
                    width: 50,
                  ),
                  height: 50,
                  width: 50,
                ),
              ),
              SizedBox(width: 5.0),
              BText(
                ordersModel?.merchantName,
                variant: TypographyVariant.h1,
                // style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          BText(
            locale
                .getTranslatedValue(
                    ordersModel.orderStatus.asString().toLowerCase())
                .capitalize(),
            variant: TypographyVariant.h1,
            style: TextStyle(color: Colors.green),
          )
        ],
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMerchantImage(context),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: BText(
                locale.getTranslatedValue(KeyConstants.orderNumber),
                variant: TypographyVariant.h2,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            Flexible(
              child: BText(
                ordersModel?.orderNumber ??
                    locale.getTranslatedValue(KeyConstants.orderNumber),
                variant: TypographyVariant.h2,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                textAlign: TextAlign.right,
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
                locale.getTranslatedValue(KeyConstants.dateOfOrder),
                variant: TypographyVariant.h2,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            Flexible(
              child: BText(
                DateFormat("dd-MM-yyyy").format(ordersModel?.createdAt) ??
                    locale.getTranslatedValue(KeyConstants.dateOfOrder),
                variant: TypographyVariant.h2,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
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
                locale.getTranslatedValue(KeyConstants.modeOfOrder),
                variant: TypographyVariant.h2,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            Flexible(
              child: BText(
                locale
                    .getTranslatedValue(
                        ordersModel.orderMode.asString().toLowerCase())
                    .capitalize(),
                variant: TypographyVariant.h2,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
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
                locale.getTranslatedValue(KeyConstants.totalItems),
                variant: TypographyVariant.h2,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            Flexible(
              child: BText(
                ordersModel?.totalItems.toString() ??
                    locale.getTranslatedValue(KeyConstants.totalItems),
                variant: TypographyVariant.h2,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BText(
              locale.getTranslatedValue(KeyConstants.items),
              variant: TypographyVariant.h2,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Flexible(
                      child: BText(
                        "₹ ${ordersModel?.items[index]?.price?.toStringAsFixed(2)}" ??
                            locale.getTranslatedValue(KeyConstants.itemName),
                        variant: TypographyVariant.h2,
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w400),
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
                variant: TypographyVariant.h2,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            Flexible(
              child: BText(
                "₹ ${ordersModel.totalAmount + ordersModel.discount}" ??
                    locale.getTranslatedValue(KeyConstants.subTotal),
                variant: TypographyVariant.h2,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
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
                locale.getTranslatedValue(KeyConstants.discount),
                variant: TypographyVariant.h2,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            Flexible(
              child: BText(
                "₹ ${ordersModel.discount.toStringAsFixed(2)}" ??
                    locale.getTranslatedValue(KeyConstants.discount),
                variant: TypographyVariant.h2,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
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
                locale.getTranslatedValue(KeyConstants.total),
                variant: TypographyVariant.h2,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            Flexible(
              child: BText(
                "₹ ${ordersModel.totalAmount.toStringAsFixed(2)}" ??
                    locale.getTranslatedValue(KeyConstants.total),
                variant: TypographyVariant.h2,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
