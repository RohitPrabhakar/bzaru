import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/customer/c_order_state.dart';
import 'package:flutter_bzaru/providers/customer/c_store_state.dart';
import 'package:flutter_bzaru/providers/customer/c_time_state.dart';
import 'package:flutter_bzaru/ui/pages/personal/checkout/checkout_screen.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class CartBNB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CStoreState>(
      builder: (context, state, child) {
        final locale = AppLocalizations.of(context);

        double totalAmount = state.getTotalAmount(state.personalCart);
        return totalAmount > 0
            ? GestureDetector(
                onTap: () async {
                  print("HELLO");
                  if (totalAmount > 0) {
                    final orderState =
                        Provider.of<COrderState>(context, listen: false);
                    orderState.setCheckoutCart(state.personalCart);

                    final timeState =
                        Provider.of<CTimeState>(context, listen: false);

                    timeState.setMerchantIdAndOrders(
                        state.merchantsIds, state.personalCart);
                    timeState.fetchAvailableTimings();

                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => CheckoutScreen()));
                  }
                },
                child: Container(
                  color: KColors.customerPrimaryColor,
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(width: 60),
                      BText(
                        locale.getTranslatedValue(KeyConstants.goToCheckout),
                        variant: TypographyVariant.titleSmall,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            BText(
                              "Total ",
                              variant: TypographyVariant.h4,
                              style: TextStyle(
                                color: Color(0xff707070),
                              ),
                            ),
                            BText(
                              "₹${totalAmount.toStringAsFixed(2)}",
                              variant: TypographyVariant.h1,
                              style: TextStyle(
                                color: Color(0xff707070),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            : SizedBox();
      },
    );
  }
}
