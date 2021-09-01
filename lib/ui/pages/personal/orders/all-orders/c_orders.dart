import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/customer/c_order_state.dart';
import 'package:flutter_bzaru/ui/pages/personal/orders/all-orders/widgets/customer_order_tile.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_app_bar.dart';
import 'package:flutter_bzaru/ui/widgets/overlay_loading.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class COrders extends StatefulWidget {
  @override
  _COrdersState createState() => _COrdersState();
}

class _COrdersState extends State<COrders> {
  ValueNotifier<bool> _isLoading;
  String langCode;

  @override
  void initState() {
    _isLoading = ValueNotifier<bool>(false);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      langCode = await SharedPrefrenceHelper().getLanguageCode();
      await getOrdersList();
    });
    super.initState();
  }

  @override
  void dispose() {
    _isLoading.dispose();
    super.dispose();
  }

  Future<void> getOrdersList() async {
    _isLoading.value = true;
    final customerId = await SharedPrefrenceHelper().getAccessToken();
    final state = Provider.of<COrderState>(context, listen: false);
    await state.getCustomerOrderList(customerId);
    _isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.myOrders),
        bgColor: KColors.customerPrimaryColor,
      ),
      body: ValueListenableBuilder(
        valueListenable: _isLoading,
        builder: (context, isLoading, child) => isLoading
            ? OverlayLoading(
                showLoader: _isLoading,
                bgScreenColor: Colors.white,
                loadingMessage:
                    locale.getTranslatedValue(KeyConstants.fetchingOrders),
              )
            : Consumer<COrderState>(builder: (context, state, child) {
                final list = state.myOrderList?.reversed?.toList();
                print(list);
                return list != null && list.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: list.length,
                        padding: EdgeInsets.only(top: 10, bottom: 60),
                        itemBuilder: (context, index) {
                          return CustomerOrderTile(
                            ordersModel: list[index],
                            langCode: langCode,
                          );
                        },
                      ).pH(10)
                    : Center(
                        child: BText(
                          locale
                              .getTranslatedValue(KeyConstants.noOrdersPlaced),
                          variant: TypographyVariant.h1,
                        ),
                      );
              }),
      ),
    );
  }
}
