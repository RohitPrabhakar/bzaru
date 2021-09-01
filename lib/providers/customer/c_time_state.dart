import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/model/timing_model.dart';
import 'package:flutter_bzaru/providers/base_state.dart';
import 'package:flutter_bzaru/resource/repository/customer_repository.dart';
import 'package:flutter_bzaru/ui/pages/personal/checkout/widgets/delivery_time_slot_selection.dart';
import 'package:flutter_bzaru/ui/theme/extensions.dart';

class CTimeState extends BaseState {
  List<String> _merchantIds = [];
  List<TimingModel> _businessTimings = [];
  List<OrdersModel> _orders = [];
  Map<OrdersModel, List<TimingModel>> _merchantTimingsMap = {};
  Map<String, List<String>> _listOfTimeSlots = {};
  Map<String, DateModel> _tempSelectedDateForMercahnt = {};
  Map<String, String> _selectedTimeSlot = {};

  List<TimingModel> get businessTimings => _businessTimings;
  Map<OrdersModel, List<TimingModel>> get merchantTimingsMap =>
      _merchantTimingsMap; //Business timings map , Id & Timing
  Map<String, DateModel> get tempSelectedDate =>
      _tempSelectedDateForMercahnt; //Date selected bu Cutomer, Ids & Date map
  Map<String, List<String>> get listOfTimeSlots =>
      _listOfTimeSlots; //All available timeslots
  Map<String, String> get selectedTimeSlot =>
      _selectedTimeSlot; //selected time slot by customer

  //Setting all MerchantIds from Orders
  void setMerchantIdAndOrders(List<String> ids, List<OrdersModel> orders) {
    print("SETTING IDS ${ids.length}");
    _merchantIds = List.from(ids);
    _orders = List.from(orders);
    notifyListeners();
  }

  void setDeliveryMode(OrdersModel model, ModeOfOrder mode) {
    final order = _merchantTimingsMap.keys
        .firstWhere((element) => element.merchantId == model.merchantId);

    if (order != null) {
      order.orderMode = mode;
    }
    notifyListeners();
  }

  void setSelectedDay(DateModel date, List<TimingModel> timings) {
    final timingModel = timings.firstWhere((model) {
      if (model.day.toLowerCase().compareTo(date.day.toLowerCase()) == 0) {
        return true;
      } else {
        return false;
      }
    });
    var temp = Map<String, DateModel>();
    var tempTimeSlot = Map<String, List<String>>();

    if (_tempSelectedDateForMercahnt != null &&
        _tempSelectedDateForMercahnt.isNotEmpty) {
      temp = Map.from(_tempSelectedDateForMercahnt);
      tempTimeSlot = Map.from(_listOfTimeSlots);

      if (temp.containsKey(date.merchantId)) {
        temp.update(date.merchantId, (value) => date);
        if (timingModel != null) {
          final list =
              getAvailableTimeSlots(timingModel.startTime, timingModel.endTime);
          tempTimeSlot.update(date.merchantId, (value) => list);
        }
      } else {
        temp[date.merchantId] = date;
        if (timingModel != null) {
          final list =
              getAvailableTimeSlots(timingModel.startTime, timingModel.endTime);
          tempTimeSlot[date.merchantId] = list;
          _selectedTimeSlot[date.merchantId] = list[0];
        }
      }
    } else {
      temp.addAll({
        date.merchantId: date,
      });

      if (timingModel != null) {
        final list =
            getAvailableTimeSlots(timingModel.startTime, timingModel.endTime);
        tempTimeSlot.addAll({date.merchantId: list});
        _selectedTimeSlot.addAll({date.merchantId: list[0]});
      }
    }

    _tempSelectedDateForMercahnt = Map.from(temp);
    _listOfTimeSlots = Map.from(tempTimeSlot);
    print(_tempSelectedDateForMercahnt);
    notifyListeners();
  }

  bool checkIsSelected(DateModel date, OrdersModel order) {
    if (_tempSelectedDateForMercahnt != null) {
      if (_tempSelectedDateForMercahnt.containsValue(date)) {
        return true;
      } else {
        if (order.date != null) {
          if (order.date.date.isSameDate(date.date)) {
            return true;
          } else {
            return false;
          }
        } else {
          return false;
        }
      }
    } else {
      return false;
    }
  }

  List<String> getAvailableTimeSlots(String start, String end) {
    int startTime;
    int endTime;
    List<String> timeSlots = [];

    if (start.toLowerCase().contains("am") &&
        end.toLowerCase().contains("pm")) {
      //NORMAL CASE
      startTime = int.tryParse(start.split(":")[0]);
      endTime = int.tryParse(end.split(":")[0]) + 12;
      //
      for (int i = startTime; i < endTime; i++) {
        int j = i + 1;
        final firstSuf = i < 12 ? "A.M" : "P.M";
        final firstPre = i < 13 ? i : i - 12;

        final secondSuf = j < 12 ? "A.M" : "P.M";
        final secondPre = j < 13 ? j : j - 12;
        print("$firstPre:00 $firstSuf - $secondPre:00 $secondSuf");

        timeSlots.add("$firstPre:00 $firstSuf - $secondPre:00 $secondSuf");
      }
    } else if (start.toLowerCase().contains("pm") &&
        end.toLowerCase().contains("am")) {
      //End time is greater than start i.e night shift
      startTime = int.tryParse(start.split(":")[0]) + 12;
      endTime = int.tryParse(end.split(":")[0]) + 24;

      for (int i = startTime; i < endTime; i++) {
        int j = i + 1;
        final firstSuf = i < 24
            ? i < 12
                ? "A.M"
                : "P.M"
            : i - 24 < 12
                ? "A.M"
                : "P.M";

        final firstPre = i < 24
            ? i < 13
                ? i
                : i - 12
            : i - 24 < 13
                ? (i - 24) == 0
                    ? 12
                    : i - 24
                : i - 12;

        final secondSuf = j < 24
            ? j < 12
                ? "A.M"
                : "P.M"
            : j - 24 < 12
                ? "A.M"
                : "P.M";
        final secondPre = j < 24
            ? j < 13
                ? j
                : j - 12
            : j - 24 < 13
                ? (j - 24) == 0
                    ? 12
                    : j - 24
                : j - 12;

        timeSlots.add("$firstPre:00 $firstSuf - $secondPre:00 $secondSuf");
      }
    } else if (start.toLowerCase().contains("am") &&
        end.toLowerCase().contains("am")) {
      startTime = int.tryParse(start.split(":")[0]);
      endTime = int.tryParse(end.split(":")[0]);

      if (startTime < endTime) {
        for (int i = startTime; i < endTime; i++) {
          int j = i + 1;
          final firstSuf = "A.M";
          final firstPre = i < 13 ? i : i - 12;

          final secondSuf = "A.M";
          final secondPre = j < 13 ? j : j - 12;
          timeSlots.add("$firstPre:00 $firstSuf - $secondPre:00 $secondSuf");
        }
      } else {
        int diff = 24 - (startTime - endTime);

        for (int i = 0; i < diff; i++) {
          int tempStart = startTime + i;
          int j = tempStart + 1;

          final firstSuf = tempStart < 24
              ? tempStart < 12
                  ? "A.M"
                  : "P.M"
              : tempStart - 24 < 12
                  ? "A.M"
                  : "P.M";

          final firstPre = tempStart < 24
              ? tempStart < 13
                  ? tempStart
                  : tempStart - 12
              : tempStart - 24 < 13
                  ? (tempStart - 24) == 0
                      ? 12
                      : tempStart - 24
                  : tempStart - 12;

          final secondSuf = j < 24
              ? j < 12
                  ? "A.M"
                  : "P.M"
              : j - 24 < 12
                  ? "A.M"
                  : "P.M";
          final secondPre = j < 24
              ? j < 13
                  ? j
                  : j - 12
              : j - 24 < 13
                  ? (j - 24) == 0
                      ? 12
                      : j - 24
                  : j - 12;

          timeSlots.add("$firstPre:00 $firstSuf - $secondPre:00 $secondSuf");
        }
      }
    } else {
      startTime = int.tryParse(start.split(":")[0]);
      endTime = int.tryParse(end.split(":")[0]);

      if (startTime < endTime) {
        startTime = startTime + 12;
        endTime = endTime + 12;

        for (int i = startTime; i < endTime; i++) {
          int j = i + 1;
          final firstSuf = "A.M";
          final firstPre = i < 13 ? i : i - 12;

          final secondSuf = "A.M";
          final secondPre = j < 13 ? j : j - 12;
          timeSlots.add("$firstPre:00 $firstSuf - $secondPre:00 $secondSuf");
        }
      } else {
        int diff = 24 - (startTime - endTime);
        startTime = startTime + 12;

        for (int i = 0; i < diff; i++) {
          int tempStart = startTime + i;
          int j = tempStart + 1;

          final firstSuf = tempStart < 24
              ? tempStart < 12
                  ? "A.M"
                  : "P.M"
              : tempStart - 24 < 12
                  ? "A.M"
                  : "P.M";

          final firstPre = tempStart < 24
              ? tempStart < 13
                  ? tempStart
                  : tempStart - 12
              : tempStart - 24 < 13
                  ? (tempStart - 24) == 0
                      ? 12
                      : tempStart - 24
                  : tempStart - 24 > 12
                      ? tempStart - 24 - 12
                      : tempStart - 24;

          final secondSuf = j < 24
              ? j < 12
                  ? "A.M"
                  : "P.M"
              : j - 24 < 12
                  ? "A.M"
                  : "P.M";
          final secondPre = j < 24
              ? j < 13
                  ? j
                  : j - 12
              : j - 24 < 13
                  ? (j - 24) == 0
                      ? 12
                      : j - 24
                  : j - 24 > 12
                      ? j - 24 - 12
                      : j - 24;

          timeSlots.add("$firstPre:00 $firstSuf - $secondPre:00 $secondSuf");
        }
      }
    }

    print(timeSlots);
    return timeSlots;
  }

  ///getting time slots for merchant
  List<String> getTimeSlots(String merchantId) {
    if (_listOfTimeSlots != null) {
      if (_listOfTimeSlots.containsKey(merchantId)) {
        return _listOfTimeSlots[merchantId];
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  void setSelectedTimeSlot(String merchantId, String slot) {
    var tempSelectedTimeSlot = Map<String, String>();
    if (_selectedTimeSlot != null && _selectedTimeSlot.isNotEmpty) {
      tempSelectedTimeSlot = Map.from(_selectedTimeSlot);

      if (tempSelectedTimeSlot.containsKey(merchantId)) {
        tempSelectedTimeSlot.update(merchantId, (value) => slot);
      } else {
        tempSelectedTimeSlot[merchantId] = slot;
      }
    } else {
      tempSelectedTimeSlot.addAll({merchantId: slot});
    }

    _selectedTimeSlot = Map.from(tempSelectedTimeSlot);
    notifyListeners();
  }

  ///setting delivery date
  void setDeliveryDate(String merchantId) {
    OrdersModel order = _merchantTimingsMap.keys
        .firstWhere((element) => element.merchantId == merchantId);

    final DateModel dateModel = _tempSelectedDateForMercahnt.values
        .firstWhere((element) => element.merchantId == merchantId);

    final String timeSlot = _selectedTimeSlot[merchantId];

    DateModel selectedDate = DateModel(
      date: dateModel.date,
      day: dateModel.day,
      isSelected: true,
      merchantId: merchantId,
      month: dateModel.month,
      starTime: timeSlot.split("-")[0].trim(),
      endTime: timeSlot.split("-")[1].trim(),
    );

    if (order != null) {
      order.date = selectedDate;
      order.orderDeliveryDate = dateModel.date;
      order.timeSlot = TimingModel(
        startTime: timeSlot.split("-")[0].trim(),
        endTime: timeSlot.split("-")[1].trim(),
      );
    }
    notifyListeners();
  }

  void clearState() {
    _merchantIds?.clear();
    _businessTimings?.clear();
    _orders?.clear();
    _merchantTimingsMap?.clear();
    _listOfTimeSlots?.clear();
    _tempSelectedDateForMercahnt?.clear();
    _selectedTimeSlot?.clear();
    notifyListeners();
  }

  ///`Fetching business timing`
  Future<void> fetchAvailableTimings() async {
    final repo = getit.get<CustomerRepository>();
    Map<OrdersModel, List<TimingModel>> tempMap =
        Map<OrdersModel, List<TimingModel>>();

    for (String id in _merchantIds) {
      final order = _orders.firstWhere((element) => element.merchantId == id);

      final list = await execute(() async {
        return await repo.fetchAvailableTimings(id);
      }, label: "fetchAvailableTimings");

      if (list != null && list.isNotEmpty) {
        _businessTimings = List.from(list);
        print(_businessTimings);
        tempMap.addAll({order: _businessTimings});
      } else {
        _businessTimings = [];
      }
    }

    _merchantTimingsMap = Map.from(tempMap);
    print(_merchantTimingsMap);

    notifyListeners();
  }
}
