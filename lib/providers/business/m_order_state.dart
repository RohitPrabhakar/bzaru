import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/providers/base_state.dart';
import 'package:flutter_bzaru/resource/repository/order_repository.dart';
import 'package:flutter_bzaru/resource/services/listeners/firebase_listeners.dart';
import 'package:url_launcher/url_launcher.dart';

class MOrderState extends BaseState {
  List<OrdersModel> _listOfAllOrders = []; // Stores all orders
  List<OrdersModel> _listOfNewOrders = []; // Stores only new orders
  List<OrdersModel> _listOfClosedOrders = []; //Stores Closed Orders
  List<OrdersModel> displayOrderList = []; //Stores list that will be displayed
  List<ProductModel> tempEditItemList; //Stores Temp Items, to alter Order
  List<ProductModel>
      displayOrderProductList; //Stores & display actual Temp Items, to alter Order

  List<OrdersModel> get listOfAllOrders => _listOfAllOrders;

  OrderType selectedOrderType = OrderType.NEW;
  OrdersModel _selectedOrder;
  double totalAmount = 0.0;
  double discount = 0.0;
  OrderStatus _orderStatus;

  OrdersModel get selectedOrder => _selectedOrder; //Holds Selected Order

  ///TEMP Value to hold status
  OrderStatus get orderStatus => _orderStatus;

  ///TO Get latest status
  void getOrderStatus() {
    _orderStatus = _selectedOrder.orderStatus;
    notifyListeners();
  }

  ///`<------------------------------------------ SETTERS----------------------------------------------------->`

  ///setting selected order
  void setSelectedOrder(OrdersModel ordersModel) {
    displayOrderProductList = List<ProductModel>();
    tempEditItemList = List<ProductModel>();
    _selectedOrder = ordersModel;
    totalAmount = _selectedOrder.totalAmount;
    displayOrderProductList = List.from(_selectedOrder.items);
    notifyListeners();
  }

  ///Changing Order Status Here
  void setOrderStatus(OrderStatus status) {
    _orderStatus = status;
    notifyListeners();
  }

  ///`<------------------------------------------FUNCTIONS CALLS--------------------------------------------------->`

  Future<void> calculateTotalAmount() async {
    totalAmount = 0.0;
    await Future.delayed(Duration(milliseconds: 100), () {
      displayOrderProductList.forEach((model) {
        totalAmount += (model.price * model.quantity);
      });
    });
    notifyListeners();
  }

  void caluclateAmountAfterDiscount() async {
    totalAmount = totalAmount - discount;
    notifyListeners();
  }

  ///When the user presses `ADD` button to add items to list
  void addItemListToDisplayList() {
    tempEditItemList.forEach((item) {
      displayOrderProductList.add(item);
    });
    // displayOrderProductList.addAll(tempEditItemList);
    notifyListeners();
  }

  ///When User brings the counter to zero.
  void removeItemFromDisplayList(ProductModel model) {
    final index =
        displayOrderProductList.indexWhere((element) => element.id == model.id);
    displayOrderProductList.removeAt(index);
    notifyListeners();
  }

  ///clearing Display Product List
  Future<void> clearDisplayProductList() async {
    tempEditItemList = [];
    displayOrderProductList = [];
    totalAmount = 0.0;
    discount = 0.0;
    displayOrderProductList = List.from(_selectedOrder.items);
    notifyListeners();
  }

  ///clear amount
  void clearAmount() {
    totalAmount = 0.0;
    discount = 0.0;
    print("AFTER CLEARING AMOUNT: $totalAmount");
    notifyListeners();
  }

  ///adding Item to temporary list
  void addItem(ProductModel prod) {
    prod.tempQty = 1;
    tempEditItemList.add(prod);
    print("ADD LENGTH ${tempEditItemList.length}");
    notifyListeners();
  }

  ///remove Item from Temp List
  void removeItem(ProductModel prod) {
    prod.tempQty = 0;
    tempEditItemList.remove(prod);
    print("ADD REMOVE ${tempEditItemList.length}");
    notifyListeners();
  }

  //clearing Temp List
  void clearItemList() {
    tempEditItemList = [];
    notifyListeners();
  }

  ///Change Quantity of single Product
  void changeQuantity(int count, ProductModel model) {
    model.tempQty = count;
    notifyListeners();
  }

  ///Updating Quantity in Model
  Future<void> updateProductQuantity() async {
    await Future.delayed(Duration(milliseconds: 500), () {
      displayOrderProductList.forEach((model) {
        print("QUANTITY BEFORE :${model.quantity}");
        print("Temp quant BEFORE :${model.tempQty}");

        model.quantity = model.tempQty > 0 ? model.tempQty : model.quantity;
        model.tempQty = 0;

        print("QUANTITY AFTER :${model.quantity}");
        print("Temp quant AFTER :${model.tempQty}");
      });
    });

    notifyListeners();
  }

  ///Switching Orders List from here
  void switchOrdersList(OrderType orderType) {
    selectedOrderType = orderType ?? OrderType.NEW;

    if (orderType == OrderType.NEW) {
      _listOfNewOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      displayOrderList = List.from(_listOfNewOrders);
    } else {
      _listOfClosedOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      displayOrderList = List.from(_listOfClosedOrders);
    }
    notifyListeners();
  }

  ///Dividing the list between New Orders & Closed Orders
  Future<void> divideListByOrders() async {
    await Future.delayed(Duration(seconds: 1), () {
      _listOfNewOrders.clear();
      _listOfClosedOrders.clear();

      _listOfAllOrders.forEach((order) {
        print("ORder : ${order.orderNumber} , status: ${order.orderStatus}");
        if (order.orderStatus == OrderStatus.COMPLETE ||
            order.orderStatus == OrderStatus.CANCEL) {
          _listOfClosedOrders.add(order);
        } else {
          _listOfNewOrders.add(order);
        }
      });
    });
  }

  ///Apply Discount
  void applyDiscount(String textDiscount) {
    discount = double.tryParse(textDiscount);
    notifyListeners();
  }

  ///Clearing orderStatus
  void clearOrderStatus() {
    _orderStatus = null;
    notifyListeners();
  }

  void clearState() {
    _listOfAllOrders?.clear();
    _listOfNewOrders?.clear();
    _listOfClosedOrders?.clear();
    displayOrderList?.clear();
    tempEditItemList?.clear();
    displayOrderProductList?.clear();
    totalAmount = 0.0;
    discount = 0.0;
    notifyListeners();
  }

  ///`<------------------------------------------ API CALLS ----------------------------------------------------->`

  ///Getting `Merhcants Orders`
  Future getMerhcantOrderList() async {
    final repo = getit.get<OrderRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    _listOfAllOrders.clear();
    displayOrderList.clear();
    isBusy = true;

    final role = UserRole.MERCHANT;
    final merchantId = await pref.getAccessToken();
    final myOrderList = await execute(() async {
      return repo.getOrderList(merchantId, role);
    });

    if (myOrderList != null) {
      _listOfAllOrders = List.from(myOrderList);
      await divideListByOrders();
    } else {
      print("No Order found");
    }
    isBusy = false;
    notifyListeners();
  }

  ///`Updating Order`
  Future updateMerchantOrder(OrdersModel ordersModel) async {
    final repo = getit.get<OrderRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    final merchantId = await pref.getAccessToken();

    isBusy = true;
    await execute(() async {
      return repo.updateOrder(ordersModel, merchantId);
    });

    isBusy = false;
    notifyListeners();
  }

  ///`Cancelling Order`
  Future cancelMerchantOrders(OrdersModel ordersModel) async {
    final repo = getit.get<OrderRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    final merchantId = await pref.getAccessToken();

    isBusy = true;
    await execute(() async {
      return repo.cancelOrder(ordersModel, merchantId);
    });

    isBusy = false;
    notifyListeners();
  }

  ///`Updating Status`
  Future<void> updateOrderStatus(OrderStatus status) async {
    final repo = getit.get<OrderRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    final merchantId = await pref.getAccessToken();

    isBusy = true;
    OrdersModel orderModel;

    if (_selectedOrder.orderStatus == OrderStatus.COMPLETE ||
        _selectedOrder.orderStatus == OrderStatus.CANCEL) {
      return;
    } else {
      _selectedOrder.orderStatus = status ?? _selectedOrder.orderStatus;
      _selectedOrder.updatedOn = DateTime.now();
      orderModel = _selectedOrder;

      if (status == OrderStatus.COMPLETE) {
        final closedAt = DateTime.now();
        orderModel = _selectedOrder.copyWith(
          closedAt: closedAt,
          updatedOn: DateTime.now(),
        );
      }

      await execute(() async {
        return repo.updateOrderStatus(orderModel, merchantId);
      });

      await getMerhcantOrderList();
      switchOrdersList(OrderType.NEW);

      print("STATUS UPDATE");
    }

    isBusy = false;
    notifyListeners();
  }

  ///Opening `Dailer`
  Future<void> launchCaller() async {
    final customerContact = _selectedOrder.customerContact;

    final url = "tel:$customerContact";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  ///`Listener`
  StreamSubscription<QuerySnapshot> orderStream(String merchantId) {
    final repo = getit.get<FirebaseListeners>();
    final role = UserRole.MERCHANT;
    return repo.orderStream(merchantId, role);
  }
}
