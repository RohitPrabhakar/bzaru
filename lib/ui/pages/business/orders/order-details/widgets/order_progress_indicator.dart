import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/business/m_order_state.dart';
import 'package:flutter_bzaru/ui/theme/app_themes.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class OrderProgressIndicator extends StatefulWidget {
  final OrderStatus status;

  const OrderProgressIndicator({Key key, this.status = OrderStatus.PACKING})
      : super(key: key);
  @override
  _OrderProgressIndicatorState createState() => _OrderProgressIndicatorState();
}

class _OrderProgressIndicatorState extends State<OrderProgressIndicator> {
  ValueNotifier<double> _value = ValueNotifier<double>(0.00);
  OrderStatus status;
  ModeOfOrder selectedOrderMode = ModeOfOrder.DELIVERY;
  String orderMode = "";

  Future<void> animateValue() async {
    int progressFactor = 0;
    switch (status) {
      case OrderStatus.RECIEVED:
        progressFactor = 0;
        break;
      case OrderStatus.PACKING:
        progressFactor = 1;
        break;
      case OrderStatus.PACKED:
        progressFactor = 2;
        break;
      case OrderStatus.DELIVERY:
        progressFactor = 3;
        break;
      case OrderStatus.PICKUP:
        progressFactor = 3;
        break;
      case OrderStatus.COMPLETE:
        progressFactor = 4;
        break;

        break;
      default:
        progressFactor = 0;
    }
    double progress =
        (25.0 * progressFactor * .01) + (progressFactor != 0 ? .05 : 0);
    log("Progress factor: $progressFactor, value: $progress");
    for (double i = 0; i <= progress; i += .01) {
      await Future.delayed(Duration(milliseconds: 40), () {
        _value.value = i;
      });
    }
  }

  @override
  void initState() {
    status = widget.status;
    super.initState();
    animateValue().then((value) => null);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initialize();
  }

  void initialize() {
    final locale = AppLocalizations.of(context);

    selectedOrderMode =
        Provider.of<MOrderState>(context).selectedOrder.orderMode;
    orderMode = locale.getTranslatedValue(
        selectedOrderMode == ModeOfOrder.DELIVERY
            ? KeyConstants.outForDelivery
            : KeyConstants.readyForPickup);
  }

  // @override
  // void didUpdateWidget(covariant OrderProgressIndicator oldWidget) {
  //   status = widget.status;
  //   animateValue();

  //   super.didUpdateWidget(oldWidget);
  // }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Column(
      children: [
        Container(
          height: 20,
          alignment: Alignment.center,
          child: ValueListenableBuilder<double>(
            valueListenable: _value,
            builder: (context, value, child) {
              return Stack(
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: LinearProgressIndicator(
                      minHeight: 4.0,
                      backgroundColor: Colors.blue[100],
                      value: value,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          KColors.businessPrimaryColor),
                    ),
                  ),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    child: CircleAvatar(
                      backgroundColor:
                          (value == 0.0 && status == OrderStatus.RECIEVED) ||
                                  value > 0.00
                              ? KColors.businessPrimaryColor
                              : Colors.blue[100],
                      radius: 10,
                    ),
                  ),
                  // _buildDots(value, 0.00),
                  _buildDots(value, 0.25),
                  _buildDots(value, 0.50),
                  _buildDots(value, 0.75),
                  Positioned(
                    bottom: 0.0,
                    right: 0.0,
                    child: CircleAvatar(
                      backgroundColor: value == 1.0
                          ? KColors.businessPrimaryColor
                          : Colors.blue[100],
                      radius: 10,
                    ),
                  ),
                ],
              );
            },
          ),
        ).pH(20),
        SizedBox(height: 10),
        Container(
          height: 30,
          child: Stack(
            children: [
              _buildText(
                  locale.getTranslatedValue(KeyConstants.orderRecieved), 0.01),
              _buildText(locale.getTranslatedValue(KeyConstants.packing), 0.27),
              _buildText(locale.getTranslatedValue(KeyConstants.packed), 0.53),
              _buildText(orderMode, 0.75),
              _buildText(
                  locale.getTranslatedValue(KeyConstants.completed), 0.94),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDots(double value, double perWidth) {
    final width = AppThemes.fullWidth(context) - 40;

    return Positioned(
      bottom: 0.0,
      left: width * perWidth,
      child: CircleAvatar(
        radius: 10,
        backgroundColor:
            value >= perWidth ? KColors.businessPrimaryColor : Colors.blue[100],
      ),
    );
  }

  Widget _buildText(String text, double perWidth) {
    final width = AppThemes.fullWidth(context) - 40;

    return Positioned(
      top: 0.0,
      left: width * perWidth,
      child: Container(
        constraints: BoxConstraints(maxWidth: 60),
        child: BText(
          text,
          variant: TypographyVariant.h3,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
