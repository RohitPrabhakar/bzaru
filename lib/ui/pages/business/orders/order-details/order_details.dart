import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/providers/business/m_order_state.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/cancel-order/cancel_order_screen.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/edit-order/edit_order_screen.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/order-details/widgets/order_details_card.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/order-details/widgets/order_progress_indicator.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/order-details/widgets/order_status_tile.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/orders-list/widgets/orders_tile.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/overlay_loading.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class OrderDetails extends StatefulWidget {
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    Utility.initConnectivity(_connectivity, mounted);
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen(Utility.updateConnectionStatus);
    getOrderStatus();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  void getOrderStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = Provider.of<MOrderState>(context, listen: false);
      await Future.delayed(Duration.zero, () {
        state.getOrderStatus();
      });
    });
  }

  Widget _buildDetailCard(OrdersModel ordersModel) {
    return OrderDetailsCard(
      ordersModel: ordersModel,
    );
  }

  Widget _buildStatusCard() {
    return OrderProgressIndicator(
        status: Provider.of<MOrderState>(context).selectedOrder.orderStatus);
  }

  Widget _buildAcceptOrderRow(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BFlatButton(
          text: locale.getTranslatedValue(KeyConstants.accept),
          onPressed: () async {
            final state = Provider.of<MOrderState>(context, listen: false);
            _isLoading.value = true;
            await state.updateOrderStatus(
                OrderStatus.ACCEPTED); //UPDATING Status to DB
            state.getOrderStatus();
            _isLoading.value = false;
          },
          isWraped: true,
          isBold: true,
          color: KColors.businessPrimaryColor,
        ),
        BFlatButton(
          text: locale.getTranslatedValue(KeyConstants.edit),
          onPressed: () {
            Navigator.push(context,
                CupertinoPageRoute(builder: (context) => EditOrderScreen()));
          },
          isWraped: true,
          isBold: true,
          color: KColors.businessPrimaryColor,
        ),
        BFlatButton(
          text: locale.getTranslatedValue(KeyConstants.cancel),
          onPressed: () {
            Navigator.push(context,
                CupertinoPageRoute(builder: (context) => CancelOrderScreen()));
          },
          isWraped: true,
          isBold: true,
          color: KColors.businessPrimaryColor,
        ),
      ],
    );
  }

  Widget _buildOrderedProducts() {
    return Consumer<MOrderState>(
      builder: (context, state, child) => Container(
        padding: EdgeInsets.all(20),
        color: Colors.grey[100],
        child: ListView.builder(
          itemCount: state.selectedOrder.items.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return OrdersTile(productModel: state.selectedOrder.items[index]);
          },
        ),
      ),
    );
  }

  Future<void> onPop() async {
    Navigator.of(context).pop();
  }

  Widget _buildOrderStatus() {
    return OrderStatusTile(
      scaffoldKey: _scaffoldKey,
      isLoading: (value) {
        if (value != null) _isLoading.value = value;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return WillPopScope(
      onWillPop: () async {
        await onPop();
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: BAppBar(
          title: locale.getTranslatedValue(KeyConstants.orderDetails),
          onPressed: onPop,
        ),
        body: Consumer<MOrderState>(
          builder: (context, state, child) {
            final oStatus = state.selectedOrder.orderStatus;

            return state.isBusy
                ? OverlayLoading(
                    showLoader: _isLoading,
                    bgScreenColor: Colors.white,
                    loadingMessage:
                        "${locale.getTranslatedValue(KeyConstants.updatingStatus)}...",
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      _buildDetailCard(state.selectedOrder).pH(20),
                      Row(
                        children: [
                          BText(
                            oStatus == OrderStatus.CANCEL ||
                                    oStatus == OrderStatus.COMPLETE
                                ? "${locale.getTranslatedValue(KeyConstants.status)}:"
                                : "${locale.getTranslatedValue(KeyConstants.status)}",
                            variant: TypographyVariant.h1,
                          ),
                          SizedBox(width: 10),
                          oStatus == OrderStatus.CANCEL ||
                                  oStatus == OrderStatus.COMPLETE
                              ? BText(
                                  oStatus == OrderStatus.CANCEL
                                      ? locale.getTranslatedValue(
                                          KeyConstants.cancelled)
                                      : locale.getTranslatedValue(
                                          KeyConstants.completed),
                                  variant: TypographyVariant.h2,
                                )
                              : SizedBox(),
                        ],
                      ).pH(20),
                      oStatus == OrderStatus.CANCEL ||
                              oStatus == OrderStatus.COMPLETE
                          ? SizedBox()
                          : Column(
                              children: [
                                SizedBox(height: 10),
                                _buildStatusCard(),
                                SizedBox(height: 10),
                                state.orderStatus == OrderStatus.PLACED
                                    ? _buildAcceptOrderRow(context).pH(20)
                                    : _buildOrderStatus().pH(20),
                              ],
                            ),
                      SizedBox(height: 20),
                      Expanded(child: _buildOrderedProducts()),
                    ],
                  );
          },
        ),
      ),
    );
  }
}
