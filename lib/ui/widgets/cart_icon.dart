import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/providers/customer/c_store_state.dart';
import 'package:flutter_bzaru/providers/customer/c_time_state.dart';
import 'package:flutter_bzaru/ui/pages/personal/cart/cart_screen.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class CartIcon extends StatelessWidget {
  final Color color;
  final Color textColor;
  const CartIcon({Key key, this.color, this.textColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final state = Provider.of<CStoreState>(context, listen: false);
        // final timeState = Provider.of<CTimeState>(context, listen: false);

        state.updatePersonalCart();
        // timeState.setMerchantIdAndOrders(
        //     state.merchantsIds, state.personalCart);

        // timeState.fetchAvailableTimings();

        print(state.personalCart.length);
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => CartScreen(),
          ),
        );
      },
      child: Container(
        alignment: Alignment.center,
        child: Stack(
          children: [
            Container(
              height: 40,
              width: 40,
            ),
            Positioned(
              left: 0.0,
              top: 0.0,
              child: Icon(
                Icons.shopping_basket,
                color: Colors.white,
                size: 30,
              ),
            ),
            Positioned(
              right: 2.0,
              top: 0.0,
              child: Container(
                alignment: Alignment.center,
                height: 20,
                width: 20,
                child: Consumer<CStoreState>(
                  builder: (context, state, child) => BText(
                    state.calculateCartItems().toString(),
                    variant: TypographyVariant.h1,
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  color: color ?? KColors.customerPrimaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
