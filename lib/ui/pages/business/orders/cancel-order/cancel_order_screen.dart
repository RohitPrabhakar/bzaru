import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/providers/business/m_order_state.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/order-details/widgets/order_details_card.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/orders-list/widgets/orders_tile.dart';
import 'package:flutter_bzaru/ui/pages/common/common_pages.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/widgets/custom_app_bar.dart';
import 'package:flutter_bzaru/ui/widgets/custom_button.dart';
import 'package:flutter_bzaru/ui/widgets/custom_text.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/overlay_loading.dart';
import 'package:provider/provider.dart';

class CancelOrderScreen extends StatefulWidget {
  @override
  _CancelOrderScreenState createState() => _CancelOrderScreenState();
}

class _CancelOrderScreenState extends State<CancelOrderScreen> {
  OrdersModel ordersModel;
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    getOrderModel();
  }

  void getOrderModel() {
    ordersModel =
        Provider.of<MOrderState>(context, listen: false).selectedOrder;
  }

  Future<void> cancelOrder() async {
    final state = Provider.of<MOrderState>(context, listen: false);

    isLoading.value = true;

    final model = state.selectedOrder.copyWith(
      orderStatus: OrderStatus.CANCEL,
      closedAt: DateTime.now(),
      updatedOn: DateTime.now(),
    );

    await state.updateMerchantOrder(model);

    final bool isInternetAvaliable = await Utility.hasInternetConnection();

    if (isInternetAvaliable) {
      Navigator.of(context).pushAndRemoveUntil(
          CupertinoPageRoute(
              builder: (context) => BottomNavBar(
                    selectedIndex: 2,
                    selectedUserProfile: UserRole.MERCHANT,
                  )),
          (route) => false);
    } else {
      Navigator.of(context)
          .push(CupertinoPageRoute(builder: (context) => NoInternet()));
    }

    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.cancelOrder),
      ),
      body: Consumer<MOrderState>(
        builder: (context, state, child) => state.isBusy
            ? OverlayLoading(
                showLoader: ValueNotifier<bool>(state.isBusy),
                loadingMessage:
                    "${locale.getTranslatedValue(KeyConstants.cancellingOrder)}...",
              )
            : Column(
                children: [
                  SizedBox(height: 20),
                  _buildMessage().pH(20),
                  BFlatButton(
                    text: locale.getTranslatedValue(KeyConstants.cancel),
                    color: KColors.businessPrimaryColor,
                    isBold: true,
                    isWraped: true,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    onPressed: () async {
                      await cancelOrder(); //CANCELING ORDER
                    },
                  ),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey[300], thickness: 1.5),
                  SizedBox(height: 20),
                  _buildOrderDetails().pH(20),
                  SizedBox(height: 10),
                  Divider(color: Colors.grey[300], thickness: 1.5),
                  SizedBox(height: 20),
                  Expanded(child: _buildProductList().pH(20)),
                  SizedBox(height: 40),
                ],
              ),
      ),
    );
  }

  Widget _buildMessage() {
    final locale = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BText(
          locale.getTranslatedValue(KeyConstants.areYourSure),
          variant: TypographyVariant.h1,
          style: TextStyle(
            color: Colors.red,
          ),
        ),
        SizedBox(height: 10),
        BText(
          locale.getTranslatedValue(KeyConstants.cancelProceed),
          variant: TypographyVariant.h2,
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildOrderDetails() {
    return OrderDetailsCard(
      ordersModel: ordersModel,
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      itemCount: ordersModel.items.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return OrdersTile(productModel: ordersModel.items[index]);
      },
    );
  }
}
