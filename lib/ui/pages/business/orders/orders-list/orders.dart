import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/orders-list/widgets/completed_orders_tile.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/orders-list/widgets/new_orders_tile.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/orders-list/widgets/orders_search_delegate.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/orders-list/widgets/orders_switch_tab.dart';
import 'package:flutter_bzaru/ui/widgets/custom_app_bar.dart';
import 'package:flutter_bzaru/ui/widgets/overlay_loading.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bzaru/providers/business/m_order_state.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String updateMsg;
  ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  @override
  void initState() {
    _isLoading.value = true;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getOrdersList();
      _isLoading.value = false;
    });
  }

  Future<void> getOrdersList() async {
    final state = Provider.of<MOrderState>(context, listen: false);
    await state.getMerhcantOrderList();
    final len = state.listOfAllOrders.length;
    print("ORDERS LEN: $len");
    await SharedPrefrenceHelper().setOrderLength(len);

    await Future.delayed(Duration.zero, () {
      state.switchOrdersList(OrderType.NEW);
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.orders),
        elevation: 0.0,
        removeLeadingIcon: true,
        trailingIcon: Icons.search,
        onTrailingPressed: () {
          final listofOrders =
              Provider.of<MOrderState>(context, listen: false).listOfAllOrders;
          showSearch(
            context: context,
            delegate: OrderSearchDelegate(
              listOfAllOrders: listofOrders,
              searchField:
                  locale.getTranslatedValue(KeyConstants.searchFieldOrder),
            ),
          );
        },
      ),
      body: Column(
        children: [
          OrdersSwitchTabs(),
          Consumer<MOrderState>(
            builder: (context, state, child) {
              final list = List.from(state.displayOrderList);
              print(state.displayOrderList.length);
              final isNew =
                  state.selectedOrderType == OrderType.NEW ? true : false;
              return ValueListenableBuilder(
                valueListenable: _isLoading,
                builder: (context, isLoading, _) {
                  return Expanded(
                    child: isLoading
                        ? OverlayLoading(
                            showLoader: _isLoading,
                            bgScreenColor: Colors.white,
                            loadingMessage: updateMsg ??
                                locale.getTranslatedValue(
                                    KeyConstants.fetchingOrders),
                          )
                        : list != null && list.isNotEmpty
                            ? Container(
                                child: ListView.builder(
                                  itemCount: list.length,
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    print(index);
                                    return Column(
                                      children: [
                                        isNew
                                            ? NewOrdersTile(
                                                ordersModel: list[index],
                                                onChangedMsg: (value) {
                                                  if (value != null &&
                                                      value.isNotEmpty) {
                                                    updateMsg = value;
                                                  }
                                                },
                                                isLoading: (value) {
                                                  if (value != null) {
                                                    _isLoading.value = value;
                                                  }
                                                },
                                              )
                                            : CompletedOrdersTile(
                                                ordersModel: list[index],
                                              ),
                                        index < list.length - 1
                                            ? Divider(
                                                height: 1.0,
                                                thickness: 1.0,
                                                color: Colors.grey)
                                            : SizedBox(height: 40),
                                      ],
                                    );
                                  },
                                ),
                              )
                            : Center(
                                child: BText(
                                  locale.getTranslatedValue(
                                      KeyConstants.noOrdersYet),
                                  variant: TypographyVariant.titleSmall,
                                ),
                              ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
