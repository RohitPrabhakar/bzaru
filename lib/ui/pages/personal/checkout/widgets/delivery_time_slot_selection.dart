import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/model/timing_model.dart';
import 'package:flutter_bzaru/providers/customer/c_order_state.dart';
import 'package:flutter_bzaru/providers/customer/c_time_state.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/widgets/custom_button.dart';
import 'package:flutter_bzaru/ui/widgets/custom_text.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DeliveryTimeSlotSelection extends StatefulWidget {
  const DeliveryTimeSlotSelection({
    Key key,
    this.timings,
    this.order,
  }) : super(key: key);

  final OrdersModel order;
  final List<TimingModel> timings;

  @override
  _DeliveryTimeSlotSelectionState createState() =>
      _DeliveryTimeSlotSelectionState();
}

class _DeliveryTimeSlotSelectionState extends State<DeliveryTimeSlotSelection> {
  List<DateModel> _weekCalendar;
  ValueNotifier<int> _selectedTimeSlot = ValueNotifier<int>(0);

  @override
  void dispose() {
    _selectedTimeSlot.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _buildCalendar();
    _setupTimeSlot();
  }

  void _setupTimeSlot() {
    if (widget.order.date != null) {
      final timeState = Provider.of<CTimeState>(context, listen: false);
      String timeslot =
          widget.order.date.starTime + " - " + widget.order.date.endTime;

      int indexOf =
          timeState.listOfTimeSlots[widget.order.merchantId].indexOf(timeslot);

      if (indexOf != null) {
        _selectedTimeSlot = ValueNotifier<int>(indexOf);
      }
    }
  }

  DropdownMenuItem<int> _buildDropDownItem(
      String text, int index, List<String> avaialbleTimings) {
    return DropdownMenuItem(
      child: BText(
        text,
        variant: TypographyVariant.h2,
        style: TextStyle(
          fontSize: 12,
        ),
      ),
      value: index,
      onTap: () {
        _selectedTimeSlot.value = index;
        final timeState = Provider.of<CTimeState>(context, listen: false);
        timeState.setSelectedTimeSlot(
            widget.order.merchantId, avaialbleTimings[index]);
      },
    );
  }

  void _buildCalendar() {
    final today = DateTime.now();
    final range =
        DateTimeRange(start: today, end: today.add(Duration(days: 6)));

    print(range);

    _weekCalendar = List<DateModel>();
    DateTime date = range.start;

    for (int i = 0; i < 7; i++) {
      final isClosed = widget.timings.firstWhere((element) {
        if (element.day
                .toLowerCase()
                .compareTo(DateFormat('EEEE').format(date).toLowerCase()) ==
            0) {
          return true;
        } else {
          return false;
        }
      }).isClosed;

      _weekCalendar.add(
        DateModel(
          date: date,
          day: DateFormat('EEEE').format(date),
          month: DateFormat('MMM').format(date),
          isClosed: isClosed,
          merchantId: widget.order.merchantId,
        ),
      );

      date = date.add(Duration(days: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Consumer<CTimeState>(
      builder: (context, timeState, child) {
        final avaialbleTimings =
            timeState.getTimeSlots(widget.order.merchantId);

        return Column(
          children: [
            Container(
              height: 40,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _weekCalendar.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final day = _weekCalendar[index];
                  final isSelected =
                      timeState.checkIsSelected(day, widget.order);

                  return GestureDetector(
                    onTap: day.isClosed
                        ? null
                        : () {
                            timeState.setSelectedDay(day, widget.timings);
                          },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      padding: EdgeInsets.all(5.0),
                      decoration: BoxDecoration(
                        color: day.isClosed
                            ? Colors.grey[400]
                            : isSelected
                                ? KColors.customerPrimaryColor
                                : Colors.green,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          BText(
                            day.day.substring(0, 3),
                            variant: TypographyVariant.h3,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          BText(
                            "${day.month} ${day.date.day}",
                            variant: TypographyVariant.h3,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: KColors.customerPrimaryColor,
                      size: 23,
                    ),
                    SizedBox(width: 2),
                    ValueListenableBuilder(
                      valueListenable: _selectedTimeSlot,
                      builder: (context, selectedIndex, child) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        color: KColors.bgColor,
                        child: DropdownButton<int>(
                          icon: Icon(Icons.keyboard_arrow_down,
                              color: KColors.customerPrimaryColor),
                          iconSize: 23,
                          underline: SizedBox(),
                          dropdownColor: Colors.white,
                          value: selectedIndex,
                          onChanged: (value) {
                            print(value);
                          },
                          items: avaialbleTimings != null &&
                                  avaialbleTimings.isNotEmpty
                              ? avaialbleTimings
                                  .asMap()
                                  .entries
                                  .map((mapEntry) {
                                  return _buildDropDownItem(mapEntry.value,
                                      mapEntry.key, avaialbleTimings);
                                }).toList()
                              : <DropdownMenuItem<int>>[
                                  DropdownMenuItem<int>(
                                    value: 0,
                                    child: SizedBox(
                                      child: Text(
                                        locale.getTranslatedValue(
                                            KeyConstants.selectADate),
                                      ),
                                    ),
                                  ),
                                ],
                        ),
                      ),
                    ),
                  ],
                ),
                BFlatButton(
                    text: locale.getTranslatedValue(KeyConstants.confirm),
                    isWraped: true,
                    color: KColors.customerPrimaryColor,
                    onPressed: () {
                      if (timeState.tempSelectedDate
                              .containsKey(widget.order.merchantId) &&
                          timeState.listOfTimeSlots
                              .containsKey(widget.order.merchantId) &&
                          timeState.selectedTimeSlot
                              .containsKey(widget.order.merchantId)) {
                        print("TRUE");
                        timeState.setDeliveryDate(widget.order.merchantId);

                        //TODO: ADD IN ORDER STATE

                        final orderState =
                            Provider.of<COrderState>(context, listen: false);

                        orderState.setDeliveryDate(
                            widget.order.merchantId, widget.order);

                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(
                            locale.getTranslatedValue(
                                KeyConstants.orderDateConfirmed),
                          ),
                        ));
                      } else {
                        print("FALSE");
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(
                            locale.getTranslatedValue(
                                KeyConstants.pleaseSelectDate),
                          ),
                        ));
                      }
                      //POP
                    }),
              ],
            )
          ],
        );
      },
    );
  }
}

class DateModel {
  DateModel({
    this.merchantId,
    this.day,
    this.month,
    this.date,
    this.isClosed,
    this.isSelected,
    this.starTime,
    this.endTime,
  });

  final String merchantId;
  final DateTime date;
  final String day;
  final String month;
  String starTime;
  String endTime;
  bool isClosed;
  bool isSelected;
}
