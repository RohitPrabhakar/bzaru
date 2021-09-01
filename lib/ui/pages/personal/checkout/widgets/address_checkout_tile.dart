import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/customer_address_model.dart';
import 'package:flutter_bzaru/providers/customer/c_order_state.dart';
import 'package:flutter_bzaru/ui/pages/personal/c-address/customer_address_screen.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class AddressCheckoutTile extends StatefulWidget {
  @override
  _AddressCheckoutTileState createState() => _AddressCheckoutTileState();
}

class _AddressCheckoutTileState extends State<AddressCheckoutTile> {
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

    return Consumer<COrderState>(
      builder: (context, state, child) {
        final primaryAddress = "${state.selectedAddress.address1} " +
            "${state.selectedAddress?.address2}";

        final secondaryAddress = "${state.selectedAddress.city}, " +
            "${state.selectedAddress.state}, " +
            "${state.selectedAddress.pinCode}";

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
                        Icons.location_pin,
                        size: 30,
                        color: KColors.customerPrimaryColor,
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: state.customerAddress.isEmpty
                            ? BFlatButton(
                                text: locale.getTranslatedValue(
                                    KeyConstants.addDeliveryAddress),
                                isWraped: true,
                                color: KColors.customerPrimaryColor,
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              CustomerAddressScreen()));
                                },
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  BText(
                                    primaryAddress ??
                                        locale.getTranslatedValue(
                                            KeyConstants.primaryBreakSafe),
                                    variant: TypographyVariant.h1,
                                    maxLines: 2,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w400),
                                  ),
                                  SizedBox(height: 5),
                                  BText(
                                    secondaryAddress ??
                                        locale.getTranslatedValue(
                                            KeyConstants.cityBreakSafe),
                                    variant: TypographyVariant.h2,
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                  ),
                                ],
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
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSecondChild(bool isExpanded) {
    print("isEXPANDED :$isExpanded");
    return SecondChildAddress(
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
class SecondChildAddress extends StatefulWidget {
  final ValueChanged<bool> onExpanded;
  final bool isExpanded;

  const SecondChildAddress({Key key, this.onExpanded, this.isExpanded})
      : super(key: key);

  @override
  _SecondChildAddressState createState() => _SecondChildAddressState();
}

class _SecondChildAddressState extends State<SecondChildAddress> {
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

    return Consumer<COrderState>(
      builder: (context, state, child) {
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
                            Icons.location_pin,
                            size: 30,
                            color: KColors.customerPrimaryColor,
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            child: BText(
                              locale.getTranslatedValue(
                                  KeyConstants.selectDeliveryAdd),
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
            ListView.builder(
              shrinkWrap: true,
              itemCount: state.customerAddress.length + 1,
              itemBuilder: (context, index) => index <=
                      state.customerAddress.length - 1
                  ? _buildAddress(state.customerAddress[index], index)
                  : GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => CustomerAddressScreen())),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add,
                              size: 30,
                              color: KColors.customerPrimaryColor,
                            ),
                            SizedBox(width: 10),
                            BText(
                                locale.getTranslatedValue(
                                    KeyConstants.addAnotherAdd),
                                variant: TypographyVariant.h1),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddress(CustomerAddressModel model, index) {
    final locale = AppLocalizations.of(context);

    final primaryAddress = "${model.address1} " + "${model?.address2}";

    final secondaryAddress =
        "${model.city}, " + "${model.state}, " + "${model.pinCode}";

    return RadioListTile<int>(
      value: index,
      activeColor: KColors.customerPrimaryColor,
      dense: false,
      title: BText(
        primaryAddress ??
            locale.getTranslatedValue(KeyConstants.primaryBreakSafe),
        variant: TypographyVariant.h1,
        maxLines: 2,
        style: TextStyle(fontWeight: FontWeight.w400),
      ),
      subtitle: BText(
        secondaryAddress ??
            locale.getTranslatedValue(KeyConstants.cityBreakSafe),
        variant: TypographyVariant.h2,
        style: TextStyle(color: Colors.grey, fontSize: 14),
      ),
      secondary: Icon(
        Icons.edit,
        size: 26,
        color: KColors.customerPrimaryColor,
      ).ripple(() {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => CustomerAddressScreen(
                      customerAddressModel: model,
                    )));
      }),
      groupValue: selectedAddressIndex,
      onChanged: (value) {
        setState(() {
          selectedAddressIndex = value;
          final state = Provider.of<COrderState>(context, listen: false);
          state.setSelectedAddress(model);
        });
      },
    );
  }
}
