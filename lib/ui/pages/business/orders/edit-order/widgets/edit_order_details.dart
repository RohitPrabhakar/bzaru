import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/providers/business/m_order_state.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bzaru/helper/enum.dart';

class EditOrderDetails extends StatefulWidget {
  final ValueChanged<ModeOfOrder> modeOfOrder;
  final ValueChanged<bool> onDiscountValidated;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const EditOrderDetails({
    Key key,
    this.modeOfOrder,
    this.onDiscountValidated,
    this.scaffoldKey,
  }) : super(key: key);

  @override
  _EditOrderDetailsState createState() => _EditOrderDetailsState();
}

class _EditOrderDetailsState extends State<EditOrderDetails> {
  OrdersModel ordersModel;
  ValueNotifier<int> groupVal = ValueNotifier<int>(0);
  TextEditingController _discountController;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getOrderModel();
    _discountController = ordersModel.discount != 0.00
        ? TextEditingController(text: ordersModel.discount.toStringAsFixed(2))
        : TextEditingController();
    _discountController = TextEditingController();
    widget.onDiscountValidated(true);
  }

  @override
  void dispose() {
    _discountController.dispose();
    super.dispose();
  }

  void getOrderModel() {
    ordersModel =
        Provider.of<MOrderState>(context, listen: false).selectedOrder;

    if (ordersModel.orderMode != null) {
      if (ordersModel.orderMode.asString() == "pickup") {
        //TODO: TEST FOR BOTH LOCALE
        groupVal.value = 0;
        widget.modeOfOrder(ModeOfOrder.PICKUP);
      } else {
        groupVal.value = 1;
        widget.modeOfOrder(ModeOfOrder.DELIVERY);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    final orderNumber = ordersModel.orderNumber ??
        locale.getTranslatedValue(KeyConstants.orderNumber);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BText(locale.getTranslatedValue(KeyConstants.order),
                      variant: TypographyVariant.h1),
                  SizedBox(width: 5.0),
                  BText("#$orderNumber", variant: TypographyVariant.h2),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  BText(
                    "${locale.getTranslatedValue(KeyConstants.name)}: ",
                    variant: TypographyVariant.h1,
                  ),
                  BText(
                    ordersModel.customerName ??
                        locale.getTranslatedValue(KeyConstants.customerName),
                    variant: TypographyVariant.h2,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDiscountField(),
                  SizedBox(width: 20),
                  Consumer<MOrderState>(
                    builder: (context, state, child) => BFlatButton(
                      text: locale.getTranslatedValue(KeyConstants.apply),
                      onPressed: () {
                        _formKey.currentState.save();

                        final bool isValidated =
                            _formKey.currentState.validate();

                        if (isValidated) {
                          widget.onDiscountValidated(true);
                          state.applyDiscount(_discountController.text);
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          currentFocus.unfocus();
                          Utility.displaySnackbar(context,
                              msg:
                                  "₹ ${_discountController.text} ${locale.getTranslatedValue(KeyConstants.discountAppliedText)}", //TODO: ADD LOCALE
                              key: widget.scaffoldKey);
                        } else {
                          widget.onDiscountValidated(false);
                        }
                      },
                      color: KColors.businessPrimaryColor,
                      isWraped: true,
                      padding: EdgeInsets.symmetric(horizontal: 30),
                    ),
                  )
                ],
              ),
            ],
          ).pH(20),
          ValueListenableBuilder<int>(
            valueListenable: groupVal,
            builder: (BuildContext context, int gValue, Widget child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  children: [
                    Row(
                      children: [
                        Radio<int>(
                          value: 0,
                          groupValue: gValue,
                          activeColor: KColors.businessPrimaryColor,
                          onChanged: (value) {
                            groupVal.value = value;
                            widget.modeOfOrder(ModeOfOrder.PICKUP);
                          },
                        ),
                        BText(locale.getTranslatedValue(KeyConstants.pickUp),
                            variant: TypographyVariant.h2),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<int>(
                          value: 1,
                          activeColor: KColors.businessPrimaryColor,
                          groupValue: gValue,
                          onChanged: (value) {
                            groupVal.value = value;
                            widget.modeOfOrder(ModeOfOrder.DELIVERY);
                          },
                        ),
                        BText(locale.getTranslatedValue(KeyConstants.delievey),
                            variant: TypographyVariant.h2),
                      ],
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  _buildDiscountField() {
    final locale = AppLocalizations.of(context);

    return Container(
      height: 70,
      width: 140,
      child: TextFormField(
        autocorrect: false,
        controller: _discountController,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          helperText: "",
          hintText: locale.getTranslatedValue(KeyConstants.discountAmount),
          filled: true,
          fillColor: Colors.white,
          hintStyle: KStyles.hintTextStyle.copyWith(fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide:
                BorderSide(width: 1.5, color: KColors.businessPrimaryColor),
          ),
          border: OutlineInputBorder(
            borderSide:
                BorderSide(width: 1.5, color: KColors.businessPrimaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(width: 1.5, color: KColors.businessPrimaryColor),
          ),
        ),
        textInputAction: TextInputAction.done,
        validator: (value) {
          if (RegExp(r'^(?!0*\.0+$)\d*(?:\.\d+)?$').hasMatch(value)) {
            return null;
          } else {
            return locale.getTranslatedValue(KeyConstants.enterAValidAmount);
          }
        },
        style: KStyles.fieldTextStyle,
        onChanged: (value) {
          final state = Provider.of<MOrderState>(context, listen: false);

          if (value.isEmpty) {
            _formKey.currentState.save();
            if (_formKey.currentState.validate()) {
              widget.onDiscountValidated(true);
              state.applyDiscount("0");
            }
          }
        },
      ),
    );
  }
}
