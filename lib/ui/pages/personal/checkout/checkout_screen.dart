import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/customer/c_order_state.dart';
import 'package:flutter_bzaru/providers/customer/c_store_state.dart';
import 'package:flutter_bzaru/providers/customer/c_time_state.dart';
import 'package:flutter_bzaru/ui/pages/personal/checkout/placing_order_screen.dart';
import 'package:flutter_bzaru/ui/pages/personal/checkout/widgets/address_checkout_tile.dart';
import 'package:flutter_bzaru/ui/pages/personal/checkout/widgets/delivery_checkout_tile.dart';
import 'package:flutter_bzaru/ui/pages/personal/checkout/widgets/items_checkout_tile.dart';
import 'package:flutter_bzaru/ui/pages/personal/checkout/widgets/phone_checkout_tile.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  ValueNotifier<bool> _isLoading;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    Utility.initConnectivity(_connectivity, mounted);
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen(Utility.updateConnectionStatus);
    _isLoading = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
        appBar: BAppBar(
          title: locale.getTranslatedValue(KeyConstants.checkout),
          removeLeadingIcon: true,
          leadingIcon: BIcon(
              iconData: Icons.arrow_back_ios,
              color: Colors.white,
              onTap: () {
                //TODO: CLEAR DELIEVERY MODE FROM HERE
                Navigator.of(context).pop();
              }),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(top: 20),
          child: Column(
            children: [
              AddressCheckoutTile().pH(20),
              Divider(thickness: 2.0),
              DeliveryCheckoutTile().pH(20),
              Divider(thickness: 2.0),
              PhoneCheckoutTile().pH(20),
              Divider(thickness: 2.0),
              ItemsCheckoutTile().pH(20),
              Divider(thickness: 2.0),
              SizedBox(height: 30),
              Consumer<COrderState>(
                builder: (context, state, child) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    child,
                    BText(
                      "₹ ${state.subtotal.toStringAsFixed(2)}" ?? "N.A",
                      variant: TypographyVariant.h1,
                    ),
                  ],
                ).pH(20),
                child: BText(locale.getTranslatedValue(KeyConstants.subTotal),
                    variant: TypographyVariant.h1),
              ),
              SizedBox(height: 30),
              Consumer<COrderState>(
                builder: (context, state, child) {
                  return BFlatButton2(
                    text: locale.getTranslatedValue(KeyConstants.placeOrder),
                    onPressed: state.selectedAddress != null &&
                            state.selectedAddress.id != null &&
                            state.isTimeEntered == true
                        ? () async {
                            if (Utility.connectionCode == 0) {
                              Utility.displaySnackbar(
                                context,
                                key: _scaffoldKey,
                                msg: locale.getTranslatedValue(
                                    KeyConstants.pleaseConnectTo),
                              );
                            } else {
                              _isLoading.value = true;
                              final storeState = Provider.of<CStoreState>(
                                  context,
                                  listen: false);
                              final timeState = Provider.of<CTimeState>(context,
                                  listen: false);

                              await state.placeOrder();

                              state.clearState();
                              storeState.clearState();
                              timeState.clearState();

                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => PlacingOrderScreen(),
                                ),
                              );
                              _isLoading.value = false;
                            }
                          }
                        : null,
                    isBold: true,
                    isWraped: true,
                    buttonColor: state.selectedAddress != null &&
                            state.selectedAddress.id != null &&
                            state.isTimeEntered == true
                        ? KColors.customerPrimaryColor
                        : KColors.bgColor,
                    isLoading: _isLoading,
                  );
                },
              ),
              SizedBox(height: 60),
            ],
          ),
        ));
  }
}
