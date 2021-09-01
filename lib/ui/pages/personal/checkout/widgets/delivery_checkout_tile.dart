import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/customer/c_time_state.dart';
import 'package:flutter_bzaru/ui/pages/personal/checkout/widgets/delivery_merchant_tile.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class DeliveryCheckoutTile extends StatefulWidget {
  @override
  _DeliveryCheckoutTileState createState() => _DeliveryCheckoutTileState();
}

class _DeliveryCheckoutTileState extends State<DeliveryCheckoutTile> {
  ValueNotifier<bool> _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _isExpanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isExpanded,
      builder: (context, expanded, child) => AnimatedContainer(
        duration: Duration(milliseconds: 100),
        curve: Curves.fastOutSlowIn,
        child: AnimatedCrossFade(
          firstChild: _buildFirstChild(),
          secondChild: _buildSecondChild(expanded),
          crossFadeState:
              expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: Duration(milliseconds: 100),
        ),
      ),
    );
  }

  Widget _buildFirstChild() {
    final locale = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () {
        _isExpanded.value = true;
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              fit: FlexFit.loose,
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.delivery_dining,
                    size: 30,
                    color: KColors.customerPrimaryColor,
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: BText(
                      locale.getTranslatedValue(KeyConstants.deliveryOptions),
                      variant: TypographyVariant.h1,
                      maxLines: 2,
                      style: TextStyle(fontWeight: FontWeight.w400),
                    ),
                  )
                ],
              ),
            ),
            Flexible(
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 40,
                color: KColors.customerPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondChild(bool isExpanded) {
    return SecondDelieveryChild(
      isExpanded: isExpanded,
      onExpanded: (value) {
        print(value);
        _isExpanded.value = value;
      },
    );
  }
}

///`<<<================================================================================>>>`
///`Expanded Tile for Address`
class SecondDelieveryChild extends StatefulWidget {
  final ValueChanged<bool> onExpanded;
  final bool isExpanded;

  const SecondDelieveryChild({Key key, this.onExpanded, this.isExpanded})
      : super(key: key);

  @override
  _SecondDelieveryChildState createState() => _SecondDelieveryChildState();
}

class _SecondDelieveryChildState extends State<SecondDelieveryChild> {
  ValueNotifier<bool> _isExpanded;

  int selectedAddressIndex = 0;

  @override
  void initState() {
    super.initState();
    _isExpanded = ValueNotifier<bool>(widget.isExpanded);
    widget.onExpanded(widget.isExpanded);
  }

  @override
  void dispose() {
    _isExpanded.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            _isExpanded.value = false;
            widget.onExpanded(_isExpanded.value);
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delivery_dining,
                        size: 30,
                        color: KColors.customerPrimaryColor,
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: BText(
                          locale
                              .getTranslatedValue(KeyConstants.deliveryOptions),
                          variant: TypographyVariant.h1,
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                      )
                    ],
                  ),
                ),
                Flexible(
                  child: Icon(
                    Icons.keyboard_arrow_up,
                    size: 40,
                    color: KColors.customerPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(thickness: 2.0),
        Consumer<CTimeState>(
          builder: (context, timeState, child) => Column(
            children: timeState.merchantTimingsMap.entries.map((mE) {
              return DeliveryMerchantTile(
                order: mE.key,
                listOfTimings: mE.value,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
