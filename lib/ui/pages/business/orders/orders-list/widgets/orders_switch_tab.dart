import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/business/m_order_state.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class OrdersSwitchTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Consumer<MOrderState>(
      builder: (context, state, child) {
        final isSelectedTypeNew =
            state.selectedOrderType == OrderType.NEW ? true : false;

        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  state.switchOrdersList(OrderType.NEW);
                },
                child: Container(
                  height: 50,
                  color: isSelectedTypeNew
                      ? Colors.white
                      : KColors.businessPrimaryColor,
                  alignment: Alignment.center,
                  child: BText(
                    locale.getTranslatedValue(KeyConstants.openOrders),
                    variant: TypographyVariant.titleSmall,
                    style: TextStyle(
                      color: isSelectedTypeNew
                          ? KColors.businessPrimaryColor
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  state.switchOrdersList(OrderType.COMPLETED);
                },
                child: Container(
                  height: 50,
                  color: isSelectedTypeNew
                      ? KColors.businessPrimaryColor
                      : Colors.white,
                  alignment: Alignment.center,
                  child: BText(
                    locale.getTranslatedValue(KeyConstants.closedOrders),
                    variant: TypographyVariant.titleSmall,
                    style: TextStyle(
                      color: isSelectedTypeNew
                          ? Colors.white
                          : KColors.businessPrimaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
