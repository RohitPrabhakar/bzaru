import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/model/customer_list_model.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/providers/base_state.dart';
import 'package:flutter_bzaru/resource/repository/bussiness_repository.dart';
import 'package:flutter_bzaru/resource/repository/order_repository.dart';

class MCustomerState extends BaseState {
  List<CustomerListModel> _allCustomers;
  List<OrdersModel> _allMerchantNotifications;
  List<OrdersModel> _displayMerchantNotifs;

  //getters
  List<CustomerListModel> get allCustomers => _allCustomers;
  List<OrdersModel> get allMerchantNotifications => _allMerchantNotifications;
  List<OrdersModel> get displayMerchantNotifs => _displayMerchantNotifs;

  //Functions
  Future<void> sortNotifications(List<OrdersModel> list) async {
    _allMerchantNotifications?.clear();
    _displayMerchantNotifs?.clear();

    await Future.delayed(Duration.zero, () {
      list.sort((a, b) => b.updatedOn.compareTo(a.updatedOn));
      _allMerchantNotifications = List.from(list);
      _displayMerchantNotifs = List.from(_allMerchantNotifications);
    });
  }

  void removeNotificationsFromDisplay(OrdersModel ordersModel, bool clearAll) {
    if (clearAll) {
      _displayMerchantNotifs.clear();
    } else
      _displayMerchantNotifs.removeWhere(
          (element) => element.orderNumber == ordersModel.orderNumber);
    notifyListeners();
  }

  void clearState() {
    _allCustomers?.clear();
    _allMerchantNotifications?.clear();
    _displayMerchantNotifs?.clear();
    notifyListeners();
  }

  ///`-----------------------------------API CALLS-----------------------------------`

  Future<void> getCustomersList() async {
    final repo = getit.get<BussinessRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    String merchantId = await pref.getAccessToken();

    isBusy = true;
    print("STARTING .....");
    _allCustomers = await execute(() async {
      return await repo.getCustomersList(merchantId);
    }, label: "getCustomerListFromMerhcant");

    isBusy = false;
    notifyListeners();
  }

  ///Notifications
  ///Fetching Notifications
  Future<void> getMerchantNotifications() async {
    final repo = getit.get<BussinessRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    String merchantId = await pref.getAccessToken();

    isBusy = true;
    print("STARTING FETCHIN NOTIFICATIONS .....");

    final list = await execute(() async {
      return await repo.getMerchantNotifications(merchantId);
    }, label: "getMErchantNotifications");

    if (list != null) {
      await sortNotifications(list);
    }

    isBusy = false;
    notifyListeners();
  }

  ///Clear Notifications
  Future<void> clearMerchantNotifications(bool clearAll, String orderId) async {
    final repo = getit.get<BussinessRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    String merchantId = await pref.getAccessToken();

    isBusy = clearAll ? true : false;
    print("CLEAR NOTIFICATIONS START .....");

    final isClear = await execute(() async {
      return await repo.clearMerchantNotifications(
          merchantId, clearAll, orderId);
    }, label: "clearMerchantNotifications");

    print("Cleared Notifications $isClear");

    isBusy = false;
    notifyListeners();
  }
}
