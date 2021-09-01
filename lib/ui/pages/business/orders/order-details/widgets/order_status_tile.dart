import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/providers/business/m_order_state.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_button.dart';
import 'package:provider/provider.dart';

class OrderStatusTile extends StatefulWidget {
  final ValueChanged<bool> isLoading;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const OrderStatusTile({Key key, this.isLoading, this.scaffoldKey})
      : super(key: key);
  @override
  _OrderStatusTileState createState() => _OrderStatusTileState();
}

class _OrderStatusTileState extends State<OrderStatusTile> {
  int _checkValue = 0;
  int _selecteVal = 0;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final selectedOrderMode =
        Provider.of<MOrderState>(context).selectedOrder.orderMode;

    return Consumer<MOrderState>(
      builder: (context, state, child) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: KColors.businessPrimaryColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: DropdownButton(
              underline: SizedBox(),
              iconEnabledColor: KColors.businessPrimaryColor,
              icon: Icon(Icons.keyboard_arrow_down),
              dropdownColor: Colors.white,
              style:
                  KStyles.h1.copyWith(color: Colors.black, letterSpacing: 0.5),
              value: OrdersModel.valueFromOrderStatus(state.orderStatus) ?? 0,
              items: [
                DropdownMenuItem(
                  child: Text(
                      locale.getTranslatedValue(KeyConstants.updateStatus)),
                  value: 0,
                ),
                DropdownMenuItem(
                  child: Text(
                      locale.getTranslatedValue(KeyConstants.orderRecieved)),
                  onTap: () => state.setOrderStatus(OrderStatus.RECIEVED),
                  value: 1,
                ),
                DropdownMenuItem(
                  child: Text(locale.getTranslatedValue(KeyConstants.packing)),
                  onTap: () => state.setOrderStatus(OrderStatus.PACKING),
                  value: 2,
                ),
                DropdownMenuItem(
                  child: Text(locale.getTranslatedValue(KeyConstants.packed)),
                  onTap: () => state.setOrderStatus(OrderStatus.PACKED),
                  value: 3,
                ),
                selectedOrderMode == ModeOfOrder.DELIVERY
                    ? DropdownMenuItem(
                        child: Text(locale
                            .getTranslatedValue(KeyConstants.outForDelivery)),
                        onTap: () => state.setOrderStatus(OrderStatus.DELIVERY),
                        value: 4,
                      )
                    : DropdownMenuItem(
                        child: Text(locale
                            .getTranslatedValue(KeyConstants.readyForPickup)),
                        onTap: () => state.setOrderStatus(OrderStatus.PICKUP),
                        value: 6,
                      ),
                DropdownMenuItem(
                  child:
                      Text(locale.getTranslatedValue(KeyConstants.completed)),
                  onTap: () => state.setOrderStatus(OrderStatus.COMPLETE),
                  value: 5,
                ),
              ],
              onChanged: (int value) {
                _checkValue = value; //TO KEEP CHECK
                _selecteVal = value;
              },
            ),
          ),
          BFlatButton(
            text: locale.getTranslatedValue(KeyConstants.update),
            padding: EdgeInsets.symmetric(horizontal: 10),
            isWraped: true,
            isBold: true,
            color: KColors.businessPrimaryColor,
            onPressed: () async {
              if (_checkValue == 0 &&
                  state.orderStatus == OrderStatus.ACCEPTED) {
                Utility.displaySnackbar(context,
                    msg: locale
                        .getTranslatedValue(KeyConstants.pleaseSelectStatus));
              } else {
                final locale = AppLocalizations.of(context);
                if (Utility.connectionCode == 0) {
                  Utility.displaySnackbar(
                    context,
                    key: widget.scaffoldKey,
                    msg:
                        locale.getTranslatedValue(KeyConstants.pleaseConnectTo),
                  );
                } else {
                  widget.isLoading(true);
                  await state.updateOrderStatus(state.orderStatus);
                  widget.isLoading(false);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
