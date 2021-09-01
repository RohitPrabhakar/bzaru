import 'package:flutter/cupertino.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/model/customer_address_model.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/providers/base_state.dart';
import 'package:flutter_bzaru/resource/repository/customer_repository.dart';
import 'package:flutter_bzaru/resource/repository/order_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class COrderState extends BaseState {
  List<OrdersModel> _myOrderList = [];
  List<OrdersModel> _myCart = [];

  List<OrdersModel> _allCustomerNotifications;
  List<OrdersModel> _displayCustomerNotifs;

  List<CustomerAddressModel> _customerAddress = [];
  List<CustomerAddressModel> _setcustomerAddressList = [];

  CustomerAddressModel _selectedAddress;
  Map<String, String> _instructionsMap = {};

  List<String> _orderIds = [];

  //getters
  List<OrdersModel> get allCustomerNotifications => _allCustomerNotifications;

  List<OrdersModel> get displayCustomerNotifs => _displayCustomerNotifs;

  List<OrdersModel> get myOrderList => _myOrderList;

  List<OrdersModel> get myCart => _myCart;

  List<CustomerAddressModel> get customerAddress => _customerAddress;

  CustomerAddressModel get selectedAddress => _selectedAddress;

  Map<String, String> get instructionsMap => _instructionsMap;

  ///clear Ids
  void clearOrderIds() {
    _orderIds.clear();
    notifyListeners();
  }

  ///`Checkout`
  double _subtotal = 0.0;
  int _totalItems = 0;
  String _contactNumber = "";
  List<String> _itemsImages = [];

  double get subtotal => _subtotal;

  int get totalItems => _totalItems;

  String get contactNumber => _contactNumber;

  List<String> get itemImages => _itemsImages;

  ///Setting Checkout Cart from [CartBNB]
  void setCheckoutCart(List<OrdersModel> orders) async {
    _myCart.clear();
    _subtotal = 0.0;
    _totalItems = 0;
    _contactNumber = "";
    _itemsImages.clear();
    _myCart = List.from(orders);

    final pref = getit.get<SharedPrefrenceHelper>();
    final customer = await pref.getUserProfile();

    await pref.setCustomerCart(_myCart); //Setting the cart to Shared Pref

    _myCart.forEach((order) {
      _subtotal += order.totalAmount;
      _totalItems += order.totalItems;
      order.orderMode = ModeOfOrder.DELIVERY;

      order.items.forEach((prod) {
        if (prod.imageUrl != null && prod.imageUrl.isNotEmpty) {
          _itemsImages.add(prod.imageUrl[0]);
        }
      });
    });

    final contact = _selectedAddress.mobileNumber ?? customer.contactPrimary;

    if (contact.length > 10) {
      _contactNumber = contact.substring(3);
    } else {
      _contactNumber = contact;
    }

    notifyListeners();
  }

  void setDeliveryMode(OrdersModel model, ModeOfOrder mode) {
    final order =
        _myCart.firstWhere((element) => element.merchantId == model.merchantId);

    if (order != null) {
      order.orderMode = mode;
    }
  }

  void clearState() {
    _myOrderList?.clear();
    _myCart?.clear();
    _subtotal = 0.0;
    _totalItems = 0;
    _contactNumber = "";
    _itemsImages?.clear();
    _isTimeEntered = false;
    _instructionsMap?.clear();
    print("CLEAR STATE");
    notifyListeners();
  }

  void setInstruction(String instructions, OrdersModel orderModel) {
    if (_instructionsMap != null) {
      if (_instructionsMap.containsKey(orderModel.merchantId)) {
        _instructionsMap.update(orderModel.merchantId, (value) => instructions);
      } else {
        _instructionsMap[orderModel.merchantId] = instructions;
      }
    } else {
      _instructionsMap.addAll({orderModel.merchantId: instructions});
    }
    notifyListeners();
  }

  String getInstruction(String merchantId) {
    if (_instructionsMap != null) {
      if (_instructionsMap.containsKey(merchantId)) {
        return _instructionsMap[merchantId];
      } else {
        return "";
      }
    } else {
      return "";
    }
  }

  void clearInstructions() {
    _instructionsMap.clear();
    notifyListeners();
  }

  //Functions
  Future<void> sortNotifications(List<OrdersModel> list) async {
    _allCustomerNotifications?.clear();
    _displayCustomerNotifs?.clear();

    await Future.delayed(Duration.zero, () {
      list.sort((a, b) => b.updatedOn.compareTo(a.updatedOn));
      _allCustomerNotifications = List.from(list);
      _displayCustomerNotifs = List.from(_allCustomerNotifications);
    });
  }

  void removeNotificationsFromDisplay(OrdersModel ordersModel, bool clearAll) {
    if (clearAll) {
      _displayCustomerNotifs.clear();
    } else
      _displayCustomerNotifs.removeWhere(
          (element) => element.orderNumber == ordersModel.orderNumber);
    notifyListeners();
  }

  ///`Setting selected address`
  void setSelectedAddress(CustomerAddressModel model) {
    _selectedAddress = model;
    notifyListeners();
  }

  ///`Adding Customer Address to temp list`
  void addCustomerAddress(CustomerAddressModel customerAddressModel) {
    _setcustomerAddressList.add(customerAddressModel);
    notifyListeners();
  }

  ///`Set Delivery date & mode from Time State`
  void setDeliveryDate(String merchantId, OrdersModel orderModelFromTimeState) {
    OrdersModel order =
        _myCart.firstWhere((element) => element.merchantId == merchantId);

    // print("ORDER FROM TIME STATE");
    // print(orderModelFromTimeState);

    if (order != null) {
      order.orderDeliveryDate = orderModelFromTimeState.orderDeliveryDate;
      order.timeSlot = orderModelFromTimeState.timeSlot;
      order.orderMode = orderModelFromTimeState.orderMode;
      order.date = orderModelFromTimeState.date;
    }
    print(order);
    checkIfTimeSelected();
    notifyListeners();
  }

  bool _isTimeEntered = false;

  bool get isTimeEntered => _isTimeEntered;

  void checkIfTimeSelected() {
    _isTimeEntered = false;
    final order = _myCart.firstWhere(
      (order) {
        if (order.orderDeliveryDate == null ||
            order.timeSlot == null ||
            order.date == null) {
          return true;
        } else {
          return false;
        }
      },
      orElse: () => null,
    );
    if (order != null) {
      _isTimeEntered = false;
    } else {
      _isTimeEntered = true;
    }

    notifyListeners();
  }

  Future<bool> placeOrder() async {
    final repo = getit.get<OrderRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    final customer = await pref.getUserProfile();
    final userId = await pref.getAccessToken();

    isBusy = true;
    bool isAdded = false;

    for (OrdersModel order in _myCart) {
      final instructions = getInstruction(order.merchantId);
      final createdAt = DateTime.now();
      final orderNumber = "${order.merchantId.substring(0, 3)}" +
          "${customer.id.substring(0, 3)}" +
          "${createdAt.microsecondsSinceEpoch}";
      print("Timestamp $orderNumber");
      final merchName = order.merchantName.split(" ")[0].length > 6
          ? order.merchantName.split(" ")[0].substring(0, 5).toLowerCase()
          : order.merchantName.split(" ")[0].toLowerCase();

      final orderId = _selectedAddress.fullName.split(" ")[0].length > 6
          ? _selectedAddress.fullName
              .split(" ")[0]
              .substring(0, 5)
              .toLowerCase()
          : customer.name.split(" ")[0].toLowerCase() +
              "-" +
              merchName +
              "-" +
              // createdAt.second.toString() +
              // "-" +
              // createdAt.day.toString() +
              // "-" +
              // createdAt.month.toString() +
              // "-" +
              // createdAt.year.toString() +
              createdAt.microsecondsSinceEpoch.toString();

      print(orderId);
      _orderIds.add(orderId);

      final OrdersModel newOrder = OrdersModel(
        createdAt: createdAt,
        orderNumber: orderId,
        updatedOn: createdAt,
        merchantId: order.merchantId,
        customerId: customer.id,
        mainCustomerName: customer.name,
        address:
            "${_selectedAddress?.address1}  ${_selectedAddress?.address2}, ${_selectedAddress?.city}, ${_selectedAddress?.state} ${_selectedAddress?.pinCode} ",
        customerContact:
            _selectedAddress?.mobileNumber ?? customer.contactPrimary,
        customerEmail: customer.email,
        orderStatus: OrderStatus.PLACED,
        totalAmount: order.totalAmount,
        totalItems: order.totalItems,
        customerName:
            _selectedAddress?.fullName ?? customer.name ?? "Not Provided",
        customerProfileImage: customer.avatar,
        discount: 0.00,
        items: List.from(order.items),
        merchantName: order.merchantName,
        merchantImage: order.merchantImage,
        instructions: instructions,
        date: order.date,
        orderDeliveryDate: order.orderDeliveryDate,
        timeSlot: order.timeSlot,
        orderMode: order.orderMode,
        merchantContact: order.merchantContact,
      );
      isAdded = await execute(() async {
        return await repo.placeNewOrder(newOrder);
      }, label: "placeOrder");
    }

    // await getCustomerOrderList(userId);
    await pref.clearCart();
    await pref.clearAddedProducts();
    isBusy = false;
    notifyListeners();
    return isAdded;
  }

  ///`Fetching Customer Oorder List`
  Future getCustomerOrderList(String customerId) async {
    final repo = getit.get<OrderRepository>();
    final role = UserRole.CUSTOMER;

    final list = await execute(() async {
      return repo.getOrderList(customerId, role);
    });

    if (list != null) {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      _myOrderList = List.from(list);
      print("Customer Orders length: ${_myOrderList.length}");
    } else {
      print("No Order found");
    }
    notifyListeners();
  }

  ///`Fetching Notifications for Customer`
  Future<void> getCustomerNotifications() async {
    final repo = getit.get<CustomerRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    String customerId = await pref.getAccessToken();

    isBusy = true;
    print("STARTING FETCHIN NOTIFICATIONS .....");

    final list = await execute(() async {
      return await repo.getCustomerNotifications(customerId);
    }, label: "getCustomerNotifications");

    if (list != null) {
      await sortNotifications(list);
    }

    isBusy = false;
    notifyListeners();
  }

  ///`Clearing Notifications`
  Future<void> clearCustomerNotifications(bool clearAll, String orderId) async {
    final repo = getit.get<CustomerRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    String customerId = await pref.getAccessToken();

    isBusy = clearAll ? true : false;
    print("CLEAR NOTIFICATIONS START .....");

    final isClear = await execute(() async {
      return await repo.clearCustomerNotifications(
          customerId, clearAll, orderId);
    }, label: "clearCustomerNotifications");

    print("Cleared Notifications $isClear");

    isBusy = false;
    notifyListeners();
  }

  ///`Saving Customers Multiple address`
  Future<void> saveCustomerAddress() async {
    final repo = getit.get<CustomerRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    String customerId = await pref.getAccessToken();

    final isSaved = await execute(() async {
      return await repo.saveCustomerAddress(
          customerId, _setcustomerAddressList);
    }, label: "saveCustomerAddress");

    print(isSaved);

    notifyListeners();
  }

  ///`Fetching Customers Multiple address`
  Future<void> getCustomerAddress() async {
    final repo = getit.get<CustomerRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    String customerId = await pref.getAccessToken();
    _customerAddress.clear();
    _setcustomerAddressList.clear();
    final tempSelectedAddress = _selectedAddress;
    _selectedAddress = CustomerAddressModel();

    final list = await execute(() async {
      return await repo.getCustomerAddress(customerId);
    }, label: "getCustomerAddress");

    if (list != null && list.isNotEmpty) {
      print("ADDRESS $list");
      _customerAddress = List.from(list);
      _setcustomerAddressList = List.from(list);

      if (tempSelectedAddress?.id != null) {
        print(tempSelectedAddress);
        final model = _customerAddress
            .firstWhere((element) => element.id == tempSelectedAddress.id);
        if (model != null) {
          setSelectedAddress(model);
        } else {
          _selectedAddress = _customerAddress[0];
        }
      } else {
        _selectedAddress = _customerAddress[0];
      }
    } else {
      print("NO ADDRESS FOUND");
    }

    notifyListeners();
  }

  ///`Fetching Customers Multiple address`
  Future<void> deleteCustomerAddress(CustomerAddressModel model) async {
    final repo = getit.get<CustomerRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    String customerId = await pref.getAccessToken();

    final isdeleted = await execute(() async {
      return await repo.deleteCustomerAddress(customerId, model);
    }, label: "deleteCustomerAddress");

    if (isdeleted) {
      print("DELETED");
    } else {
      print("CANT DELETE");
    }
    notifyListeners();
  }

  ///Opening `Dailer`
  Future<void> launchCaller(OrdersModel ordersModel) async {
    final customerContact = ordersModel.merchantContact;

    final url = "tel:$customerContact";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  //get order details from IDs
  Future<List<OrdersModel>> getOrderdDetailsFromID() async {
    final repo = getit.get<OrderRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    String customerId = await pref.getAccessToken();

    final list = await execute(() async {
      return repo.getOrderDetailsFromID(customerId, _orderIds ?? []);
    });

    if (list != null) {
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      print("Customer Orders length: ${_myOrderList.length}");
      return List.from(list);
    } else {
      print("No Order found");
      return [];
    }
  }
}
