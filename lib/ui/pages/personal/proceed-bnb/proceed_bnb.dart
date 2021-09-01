import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/customer/c_store_state.dart';
import 'package:flutter_bzaru/ui/pages/personal/cart/cart_screen.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ProceedBNB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CStoreState>(
      builder: (context, state, child) {
        final locale = AppLocalizations.of(context);

        return state.addedProductsInCart.length > 0
            ? GestureDetector(
                onTap: () async {
                  final state =
                      Provider.of<CStoreState>(context, listen: false);
                  state.updatePersonalCart();

                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => CartScreen(),
                    ),
                  );
                },
                child: Container(
                  alignment: Alignment.center,
                  color: KColors.customerPrimaryColor,
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 30,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        alignment: Alignment.center,
                        child: BText(
                          locale.getTranslatedValue(KeyConstants.reviewCart),
                          variant: TypographyVariant.titleSmall,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                        size: 23,
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
