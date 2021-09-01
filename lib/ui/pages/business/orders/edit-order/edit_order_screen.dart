import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/providers/business/m_order_state.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/add-orders/add_orders.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/edit-order/widgets/edit_order_details.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/edit-order/widgets/order_product_tile.dart';
import 'package:flutter_bzaru/ui/pages/common/common_pages.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_app_bar.dart';
import 'package:flutter_bzaru/ui/widgets/overlay_loading.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bzaru/helper/enum.dart';

class EditOrderScreen extends StatefulWidget {
  @override
  _EditOrderScreenState createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  ModeOfOrder orderMode;
  OrdersModel ordersModel;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ValueNotifier<bool> _isDiscountValidated = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Utility.initConnectivity(_connectivity, mounted);
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen(Utility.updateConnectionStatus);
  }

  ///`Updating Order`
  Future<void> updateOrder() async {
    final locale = AppLocalizations.of(context);
    if (Utility.connectionCode == 0) {
      Utility.displaySnackbar(
        context,
        key: _scaffoldKey,
        msg: locale.getTranslatedValue(KeyConstants.pleaseConnectTo),
      );
    } else {
      final state = Provider.of<MOrderState>(context, listen: false);
      isLoading.value = true;
      await state.updateProductQuantity();
      await state.calculateTotalAmount();

      // CHECKING DISCOUT IS NOT GREATER
      if (state.discount > state.totalAmount) {
        isLoading.value = false;
        Utility.displaySnackbar(context,
            msg: locale.getTranslatedValue(KeyConstants.discountCantBeGreater),
            key: _scaffoldKey);
      } else {
        state.caluclateAmountAfterDiscount();
        final model = state.selectedOrder.copyWith(
          orderMode: orderMode ?? ordersModel.orderMode,
          items: state.displayOrderProductList,
          totalItems: state.displayOrderProductList.length,
          totalAmount: state.totalAmount,
          discount: state.discount,
          updatedOn: DateTime.now(),
        );
        await state.updateMerchantOrder(model);
        state.clearAmount();
        await state.getMerhcantOrderList();

        state.switchOrdersList(OrderType.NEW);

        final selectedModel = state.displayOrderList
            .firstWhere((element) => element.orderNumber == model.orderNumber);
        state.setSelectedOrder(selectedModel);

        final bool isInternetAvaliable = await Utility.hasInternetConnection();

        if (isInternetAvaliable) {
          Navigator.of(context).pop(() {
            isLoading.value = false;
          });
        } else {
          Navigator.of(context)
              .push(CupertinoPageRoute(builder: (context) => NoInternet()));
        }
      }
    }
  }

  ///`On Pop`
  Future<void> onPop() async {
    if (Navigator.canPop(context)) {
      await Provider.of<MOrderState>(context, listen: false)
          .clearDisplayProductList();

      Navigator.of(context).pop();
    }
  }

  Widget _buildOrderItems(List<ProductModel> list) {
    return Column(
        children: list
            .map((model) => OrderProductTile(productModel: model))
            .toList());
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
          title: locale.getTranslatedValue(KeyConstants.editOrder),
          onPressed: onPop,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                CupertinoPageRoute(builder: (context) => AddOrderScreen()));
          },
          child: Icon(Icons.add, size: 40),
          backgroundColor: KColors.businessPrimaryColor,
        ),
        body: Stack(
          children: [
            Consumer<MOrderState>(
              builder: (context, state, child) => Column(
                children: [
                  SizedBox(height: 20),
                  EditOrderDetails(
                    modeOfOrder: (value) {
                      if (value != null) {
                        orderMode = value;
                      }
                    },
                    onDiscountValidated: (value) {
                      _isDiscountValidated.value = value;
                    },
                    scaffoldKey: _scaffoldKey,
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildOrderItems(state.displayOrderProductList)
                              .pH(20),
                          SizedBox(height: 40),
                          ValueListenableBuilder(
                            valueListenable: _isDiscountValidated,
                            builder: (context, validated, _) {
                              return BFlatButton(
                                  text: locale
                                      .getTranslatedValue(KeyConstants.update),
                                  isWraped: true,
                                  padding: EdgeInsets.symmetric(horizontal: 30),
                                  isBold: true,
                                  onPressed: () async {
                                    if (validated) {
                                      await updateOrder();
                                    }
                                  },
                                  color: validated
                                      ? KColors.businessPrimaryColor
                                      : KColors.disableButtonColor);
                            },
                          ),
                          SizedBox(height: 40),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            OverlayLoading(
              showLoader: isLoading,
              loadingMessage:
                  locale.getTranslatedValue(KeyConstants.updatingOrder),
            ),
          ],
        ),
      ),
    );
  }
}
