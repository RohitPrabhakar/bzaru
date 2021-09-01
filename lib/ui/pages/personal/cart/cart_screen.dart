import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/providers/customer/c_order_state.dart';
import 'package:flutter_bzaru/providers/customer/c_store_state.dart';
import 'package:flutter_bzaru/providers/customer/c_time_state.dart';
import 'package:flutter_bzaru/ui/pages/personal/cart/widgets/cart_bnb.dart';
import 'package:flutter_bzaru/ui/pages/personal/cart/widgets/cart_order_item.dart';
import 'package:flutter_bzaru/ui/pages/personal/cart/widgets/cart_store_tile.dart';
import 'package:flutter_bzaru/ui/pages/personal/cart/widgets/cart_tile.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/widgets/custom_app_bar.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    getCustomerAddress();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCustomerAddress();
  }

  void getCustomerAddress() async {
    final state = Provider.of<COrderState>(context, listen: false);
    await state.getCustomerAddress();
  }

  void clearState() {
    final timeState = Provider.of<CTimeState>(context, listen: false);
    final state = Provider.of<COrderState>(context, listen: false);

    timeState.clearState();
    state.clearInstructions();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return WillPopScope(
      onWillPop: () async {
        clearState();
        return true;
      },
      child: Scaffold(
        appBar: BAppBar(
          title: locale.getTranslatedValue(KeyConstants.personalCart),
          bgColor: KColors.customerPrimaryColor,
          removeLeadingIcon: true,
          leadingIcon: BIcon(
            iconData: Icons.arrow_back_ios,
            color: Colors.white,
            onTap: () {
              clearState();
              Navigator.of(context).pop();
            },
          ),
        ),
        bottomNavigationBar: CartBNB(),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(top: 10),
          child: Consumer<CStoreState>(
            builder: (context, state, child) => state.personalCart.isEmpty
                ? Container(
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: Center(
                      child: BText(
                        "${locale.getTranslatedValue(KeyConstants.oopsCartEmpty)} :(",
                        variant: TypographyVariant.h1,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  )
                : Column(
                    children: state.personalCart
                        .map(
                          (order) => CartTile(ordersModel: order),
                        )
                        .toList()),
          ),
        ),
      ),
    );
  }
}
