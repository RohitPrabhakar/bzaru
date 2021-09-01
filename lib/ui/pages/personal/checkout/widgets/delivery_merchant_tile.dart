import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/model/timing_model.dart';
import 'package:flutter_bzaru/providers/customer/c_order_state.dart';
import 'package:flutter_bzaru/providers/customer/c_time_state.dart';
import 'package:flutter_bzaru/ui/pages/personal/checkout/widgets/delivery_time_slot_selection.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';

class DeliveryMerchantTile extends StatefulWidget {
  final OrdersModel order;
  final List<TimingModel> listOfTimings;

  const DeliveryMerchantTile({Key key, this.order, this.listOfTimings})
      : super(key: key);

  @override
  _DeliveryMerchantTileState createState() => _DeliveryMerchantTileState();
}

class _DeliveryMerchantTileState extends State<DeliveryMerchantTile> {
  ValueNotifier<bool> isSecondaryExpanded = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isSecondaryExpanded,
      builder: (context, isSecExpand, child) => AnimatedContainer(
        duration: Duration(milliseconds: 100),
        curve: Curves.fastOutSlowIn,
        child: AnimatedCrossFade(
          firstChild: GestureDetector(
            onTap: () {
              isSecondaryExpanded.value = true;
            },
            child: _buildFirstChild(),
          ),
          secondChild: _buildSecondChild((value) {
            if (value != null) {
              isSecondaryExpanded.value = value;
            }
          }),
          crossFadeState: isSecExpand
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: Duration(milliseconds: 100),
        ),
      ),
    );
  }

  Widget _buildFirstChild() {
    final locale = AppLocalizations.of(context);
    print(widget.order.orderMode.asString());

    final mode = widget.order.orderMode != null
        ? "${locale.getTranslatedValue(KeyConstants.mode)}: ${locale.getTranslatedValue(widget.order.orderMode.asString())}"
        : locale.getTranslatedValue(KeyConstants.noSelectedMode);

    final selectedDate = widget.order.date != null
        ? DateTime.now().day == (widget.order.date.date.day) &&
                DateTime.now().month == (widget.order.date.date.month)
            ? "Today, ${widget.order.date.month} ${widget.order.date.date.day}, b/w ${widget.order.date.starTime} - ${widget.order.date.endTime}"
            : "${widget.order.date.day}, ${widget.order.date.month} ${widget.order.date.date.day}, b/w ${widget.order.date.starTime} - ${widget.order.date.endTime}"
        : locale.getTranslatedValue(KeyConstants.noSelectedDate);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: BText(
                  widget.order.merchantName,
                  variant: TypographyVariant.h3,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              Flexible(
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 23,
                  color: KColors.customerPrimaryColor,
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 2,
                child: BText(
                  selectedDate,
                  variant: TypographyVariant.h2,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
              Flexible(
                child: BText(
                  mode,
                  variant: TypographyVariant.h2,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSecondChild(ValueChanged<bool> onExpanded) {
    final locale = AppLocalizations.of(context);

    ValueNotifier<int> groupValue =
        ValueNotifier<int>(widget.order.orderMode != null
            ? widget.order.orderMode == ModeOfOrder.DELIVERY
                ? 1
                : 2
            : 1);
    final timeState = Provider.of<CTimeState>(context, listen: false);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          //*Building TITLE
          GestureDetector(
            onTap: () {
              onExpanded(false);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: BText(
                    widget.order.merchantName,
                    variant: TypographyVariant.h3,
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Flexible(
                  child: Icon(
                    Icons.clear,
                    size: 23,
                    color: KColors.customerPrimaryColor,
                  ),
                )
              ],
            ),
          ),

          //*Building Deleivery Mode
          ValueListenableBuilder(
            valueListenable: groupValue,
            builder: (context, gValue, child) => Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Radio(
                      value: 1,
                      groupValue: gValue,
                      onChanged: (value) {
                        final orderState =
                            Provider.of<COrderState>(context, listen: false);

                        groupValue.value = value;
                        timeState.setDeliveryMode(
                            widget.order, ModeOfOrder.DELIVERY);
                        orderState.setDeliveryMode(
                            widget.order, ModeOfOrder.DELIVERY);
                      },
                      activeColor: KColors.customerPrimaryColor,
                    ),
                    BText(
                      locale.getTranslatedValue(KeyConstants.delievey),
                      variant: TypographyVariant.h2,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Radio(
                      value: 2,
                      groupValue: gValue,
                      onChanged: (value) {
                        final orderState =
                            Provider.of<COrderState>(context, listen: false);

                        groupValue.value = value;
                        timeState.setDeliveryMode(
                            widget.order, ModeOfOrder.PICKUP);
                        orderState.setDeliveryMode(
                            widget.order, ModeOfOrder.PICKUP);
                      },
                      activeColor: KColors.customerPrimaryColor,
                    ),
                    BText(
                      locale.getTranslatedValue(KeyConstants.pickUp),
                      variant: TypographyVariant.h2,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          //*Building TIMESLOT
          DeliveryTimeSlotSelection(
            order: widget.order,
            timings: widget.listOfTimings,
          ),
        ],
      ),
    );
  }
}
