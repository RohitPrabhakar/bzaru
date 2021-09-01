import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/orders-list/widgets/completed_orders_tile.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/orders-list/widgets/new_orders_tile.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class OrderSearchDelegate extends SearchDelegate<OrdersModel> {
  final List<OrdersModel> listOfAllOrders;
  final String searchField;

  OrderSearchDelegate({this.listOfAllOrders, this.searchField});

  @override
  String get searchFieldLabel => searchField;

  @override
  TextStyle get searchFieldStyle => TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w400,
        fontSize: 16.0,
        fontFamily: "Roboto",
      );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final resultList = listOfAllOrders
        .where((order) =>
            order.customerName.toLowerCase().contains(query) ||
            order.orderNumber.contains(query))
        .toList();

    return resultList.isEmpty
        ? Center(
            child: BText(locale.getTranslatedValue(KeyConstants.noResult),
                variant: TypographyVariant.h2),
          )
        : Column(
            children: resultList
                .map(
                  (order) => order.orderStatus == OrderStatus.COMPLETE ||
                          order.orderStatus == OrderStatus.CANCEL
                      ? CompletedOrdersTile(ordersModel: order)
                      : NewOrdersTile(ordersModel: order),
                )
                .toList(),
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final locale = AppLocalizations.of(context);

    final list = query.isEmpty
        ? []
        : listOfAllOrders
            .where((order) =>
                order.customerName.toLowerCase().contains(query) ||
                order.orderNumber.contains(query))
            .toList();

    return list.isEmpty
        ? Center(
            child: BText(locale.getTranslatedValue(KeyConstants.noResult),
                variant: TypographyVariant.h2),
          )
        : ListView.builder(
            itemCount: list.length,
            itemBuilder: (BuildContext context, int index) {
              final order = list[index];
              return order.orderStatus == OrderStatus.COMPLETE ||
                      order.orderStatus == OrderStatus.CANCEL
                  ? CompletedOrdersTile(ordersModel: order)
                  : NewOrdersTile(ordersModel: order);
            },
          );
  }
}
