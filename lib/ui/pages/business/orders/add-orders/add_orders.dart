import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/providers/business/m_order_state.dart';
import 'package:flutter_bzaru/providers/business/product_provider.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/add-orders/widgets/add_orders_search_delegate.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/add-orders/widgets/add_prod_tile.dart';
import 'package:flutter_bzaru/ui/pages/common/common_pages.dart';
import 'package:flutter_bzaru/ui/widgets/custom_app_bar.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/overlay_loading.dart';
import 'package:flutter_bzaru/ui/widgets/search_box.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class AddOrderScreen extends StatefulWidget {
  @override
  _AddOrderScreenState createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    getMerchantProducts();
  }

  Future<void> getMerchantProducts() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      isLoading.value = true;
      final state = Provider.of<ProductProvider>(context, listen: false);
      state.clearSearchedList();
      await state.getMerchantProductList();
      isLoading.value = false;
    });
  }

  ///`On POP`
  Future<void> onPop() async {
    final state = Provider.of<MOrderState>(context, listen: false);
    final bool isInternetAvaliable = await Utility.hasInternetConnection();

    if (isInternetAvaliable) {
      Navigator.of(context).pop(() {
        state.clearItemList();
      });
    } else {
      Navigator.of(context)
          .push(CupertinoPageRoute(builder: (context) => NoInternet()));
    }
  }

  Widget _buildListOfProducts(List<ProductModel> list) {
    return Consumer<MOrderState>(
      builder: (context, state, child) {
        return Column(
          children: list.map(
            (prodModel) {
              bool isPresent = false;
              state.displayOrderProductList.forEach((element) {
                if (element.id == prodModel.id) {
                  isPresent = true;
                }
              });

              return AddProdTile(
                model: prodModel,
                isPresent: isPresent,
              );
            },
          ).toList(),
        );
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
            title: locale.getTranslatedValue(KeyConstants.editOrder),
            onPressed: onPop,
          ),
          body: Stack(
            children: [
              Consumer<ProductProvider>(builder: (context, state, child) {
                List<ProductModel> prodList = List<ProductModel>();
                prodList = state.listOfMerchantProducts;

                return Column(
                  children: [
                    SizedBox(height: 20),
                    SearchBox(
                      onTap: () {
                        showSearch(
                          context: context,
                          delegate: AddOrderSearchDelegate(
                              listOfProducts: state.listOfMerchantProducts,
                              scaffoldKey: _scaffoldKey,
                              searchField:
                                  "${locale.getTranslatedValue(KeyConstants.searchInventory)}..."),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: state.isBusy
                          ? OverlayLoading(
                              showLoader: isLoading,
                              bgScreenColor: Colors.white,
                              loadingMessage:
                                  "${locale.getTranslatedValue(KeyConstants.loadingProducts)}...",
                            )
                          : SingleChildScrollView(
                              child: prodList.isEmpty
                                  ? Container(
                                      height: 250,
                                      alignment: Alignment.bottomCenter,
                                      child: BText(
                                        locale.getTranslatedValue(
                                            KeyConstants.oopsSearchProduct),
                                        variant: TypographyVariant.titleSmall,
                                      ),
                                    )
                                  : Column(
                                      children: [
                                        _buildListOfProducts(prodList),
                                        SizedBox(height: 40),
                                        BFlatButton(
                                          text: locale.getTranslatedValue(
                                              KeyConstants.addText),
                                          isBold: true,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 30),
                                          color: KColors.businessPrimaryColor,
                                          isWraped: true,
                                          onPressed: () {
                                            final orderState =
                                                Provider.of<MOrderState>(
                                                    context,
                                                    listen: false);

                                            if (orderState
                                                    .tempEditItemList.length >
                                                0) {
                                              orderState
                                                  .addItemListToDisplayList();
                                              orderState.clearItemList();

                                              Navigator.of(context).pop();
                                            } else {
                                              Utility.displaySnackbar(
                                                context,
                                                msg: locale.getTranslatedValue(
                                                    KeyConstants
                                                        .noProductAdded),
                                                key: _scaffoldKey,
                                              );
                                            }
                                          },
                                        ),
                                        SizedBox(height: 40),
                                      ],
                                    ),
                            ),
                    )
                  ],
                ).pH(20);
              }),
            ],
          )),
    );
  }
}
