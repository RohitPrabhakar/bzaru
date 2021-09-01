import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/images.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/ui/pages/personal/orders/order-details/c_order_details.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';

class CustomerOrderTile extends StatefulWidget {
  const CustomerOrderTile({
    Key key,
    this.ordersModel,
    this.langCode,
  }) : super(key: key);

  final OrdersModel ordersModel;
  final String langCode;

  @override
  _CustomerOrderTileState createState() => _CustomerOrderTileState();
}

class _CustomerOrderTileState extends State<CustomerOrderTile> {
  String deliveredOn = "";
  String expectedBy = "";
  String items = "";
  List<String> itemsImages = [];
  String time = "";

  void getDate() async {
    final locale = AppLocalizations.of(context);

    time = DateFormat("dd MMMM y", widget.langCode)
        .format(widget.ordersModel.createdAt);

    if (widget.ordersModel.orderStatus == OrderStatus.COMPLETE) {
      int day = widget.ordersModel.closedAt.day;
      String month = DateFormat('MMM', widget.langCode)
          .format(widget.ordersModel.closedAt);
      int year = widget.ordersModel.closedAt.year;
      deliveredOn =
          "${locale.getTranslatedValue(KeyConstants.deliveredOn)} $day $month $year";
    } else {
      int day = widget.ordersModel.orderDeliveryDate.day;
      String month = DateFormat('MMM', widget.langCode)
          .format(widget.ordersModel.orderDeliveryDate);
      int year = widget.ordersModel.orderDeliveryDate.year;
      expectedBy =
          "${locale.getTranslatedValue(KeyConstants.expectedOn)} $day $month $year";
    }
  }

  void getItemsList() {
    widget.ordersModel.items.forEach((prod) {
      items = items.isEmpty ? prod.title : items + ", " + prod.title;
      itemsImages.add(prod.imageUrl != null ? prod.imageUrl[0] : "");
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    getItemsList();
    getDate();

    final order = widget.ordersModel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BText(
          time,
          variant: TypographyVariant.h3,
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          elevation: 5.0,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: customNetworkImage(
                        order?.merchantImage,
                        fit: BoxFit.cover,
                        placeholder: BPlaceHolder(height: 40, width: 40),
                        height: 40,
                        width: 40,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: BText(
                              order?.merchantName ??
                                  locale.getTranslatedValue(
                                      KeyConstants.merchantName),
                              variant: TypographyVariant.titleSmall,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          Flexible(
                            child: order.orderStatus == OrderStatus.COMPLETE ||
                                    order.orderStatus == OrderStatus.CANCEL
                                ? order.orderStatus == OrderStatus.COMPLETE
                                    ? BText(
                                        deliveredOn,
                                        variant: TypographyVariant.h3,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey,
                                        ),
                                      )
                                    : BText(
                                        locale.getTranslatedValue(
                                            KeyConstants.cancelled),
                                        variant: TypographyVariant.h3,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: KColors.redColor),
                                      )
                                : BText(
                                    expectedBy,
                                    variant: TypographyVariant.h3,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      color: KColors.customerPrimaryColor,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BText(
                      locale.getTranslatedValue(KeyConstants.captialItems),
                      variant: TypographyVariant.h1,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height: 30,
                      child: ListView(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        children: itemsImages
                            .map((image) => Container(
                                  margin: EdgeInsets.only(right: 2.0),
                                  child: customNetworkImage(
                                    image,
                                    height: 30,
                                    width: 30,
                                    fit: BoxFit.cover,
                                    defaultHolder: Image.asset(
                                      KImages.intro2,
                                      height: 30,
                                      width: 30,
                                    ),
                                    placeholder: BPlaceHolder(
                                      height: 30,
                                      width: 30,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          BText(
                            "${locale.getTranslatedValue(KeyConstants.status)}: ",
                            variant: TypographyVariant.h1,
                            style: TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                          BText(
                            locale
                                .getTranslatedValue(
                                    order.orderStatus.asString().toLowerCase())
                                .capitalize(),
                            variant: TypographyVariant.h1,
                            style: TextStyle(
                              fontSize: 14,
                              color: order.orderStatus == OrderStatus.CANCEL
                                  ? KColors.redColor
                                  : order.orderStatus == OrderStatus.COMPLETE
                                      ? Colors.green
                                      : KColors.customerPrimaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: BText(
                          "₹ ${order?.totalAmount?.toStringAsFixed(2)}" ??
                              "₹ 00.00",
                          variant: TypographyVariant.h1,
                          style: TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ).ripple(() {
          Navigator.of(context).push(CupertinoPageRoute(
              builder: (context) => COrderDetails(ordersModel: order)));
        }),
        SizedBox(height: 10),
      ],
    );
  }
}
