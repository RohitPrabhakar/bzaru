import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/customer/c_order_state.dart';
import 'package:flutter_bzaru/ui/pages/common/bnb/bnb.dart';
import 'package:flutter_bzaru/ui/pages/personal/checkout/order_confirmation_screen.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class PlacingOrderScreen extends StatefulWidget {
  @override
  _PlacingOrderScreenState createState() => _PlacingOrderScreenState();
}

class _PlacingOrderScreenState extends State<PlacingOrderScreen>
    with SingleTickerProviderStateMixin {
  // AnimationController _waveController, _loadController;
  // Duration _waveDuration, _loadDuration;
  // Animation _loadValue;
  // double _boxHeight, _boxWidth;
  // Color _boxBackgroundColor, _waveColor;
  // TextStyle _textStyle;

  @override
  void initState() {
    super.initState();
    goToConfirmation();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: BText(
          locale.getTranslatedValue(KeyConstants.placingOrder),
          variant: TypographyVariant.h1,
          style: TextStyle(color: KColors.customerPrimaryColor),
        ),
      ),
    );
  }

  void goToConfirmation() async {
    await Future.delayed(Duration(seconds: 1)).then(
      (value) async {
        final listOfOrders =
            await Provider.of<COrderState>(context, listen: false)
                .getOrderdDetailsFromID();
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => OrderConfirmationScreen(
              listOfOrders: listOfOrders ?? [],
            ),
          ),
        );
      },
    );
  }
}
