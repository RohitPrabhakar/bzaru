import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bzaru/helper/constants.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/ui/theme/extensions.dart';

class OrderService {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  OrderService({this.firestore, this.storage});

  Future<Source> getSource() async {
    final hasInternet = await Utility.hasInternetConnection();
    if (hasInternet) {
      return Source.serverAndCache;
    } else {
      return Source.cache;
    }
  }

  Future<List<OrdersModel>> getOrderList(String userId, UserRole role) async {
    String userRoleRef = role.asString();

    CollectionReference refMasterOrder =
        firestore.collection(Constants.orderMasterCollection);
    List<OrdersModel> list = <OrdersModel>[];

    print("GETTING ORDER : $userId");

    try {
      final source = await getSource();

      await refMasterOrder
          .doc(userRoleRef)
          .collection(userRoleRef)
          .doc(userId)
          .collection(Constants.orderDateDocument)
          .get(GetOptions(source: source))
          .then((qSnap) async {
        if (qSnap.docs != null && qSnap.docs.isNotEmpty) {
          for (var document in qSnap.docs) {
            await refMasterOrder
                .doc(userRoleRef)
                .collection(userRoleRef)
                .doc(userId)
                .collection(Constants.orderDateDocument)
                .doc(document.id)
                .collection(Constants.orderSubCollection)
                .get(GetOptions(source: source))
                .then((documentSnapshot) async {
              if (documentSnapshot.docs != null &&
                  documentSnapshot.docs.isNotEmpty) {
                print('Products exists on the database');

                for (var docSnapshot in documentSnapshot.docs) {
                  OrdersModel model = OrdersModel.fromJson(docSnapshot.data());
                  list.add(model);
                }
              }
            });
          }
        }
      }).catchError((error) => throw error);

      return list;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> placeNewOrder(OrdersModel model) async {
    CollectionReference refCustomer =
        firestore.collection(UserRole.CUSTOMER.asString());
    CollectionReference refMerchant =
        firestore.collection(UserRole.MERCHANT.asString());

    CollectionReference refMasterOrder =
        firestore.collection(Constants.orderMasterCollection);

    try {
      print("Initiate Place order");
      final date = DateTime.now().toString();
      final String dateDocument = date.getYearAndMonth();

      ///`creating a order reference inside merchant collection for listeners`
      await refMerchant
          .doc(model.merchantId)
          .collection(Constants.orderCollection)
          .doc(model.orderNumber)
          .set({"orderId": model.orderNumber}).catchError(
              (onError) => throw onError);

      ///`Creating Order for MERCHANT`
      await refMasterOrder
          .doc(Constants.merchantCollection)
          .set({"collection": Constants.merchantCollection});

      await refMasterOrder
          .doc(Constants.merchantCollection)
          .collection(Constants.merchantCollection)
          .doc(model.merchantId)
          .set({"merchantId": model.merchantId});

      await refMasterOrder
          .doc(Constants.merchantCollection)
          .collection(Constants.merchantCollection)
          .doc(model.merchantId)
          .collection(Constants.orderDateDocument)
          .doc(dateDocument)
          .set({"collection": dateDocument});

      await refMasterOrder
          .doc(Constants.merchantCollection)
          .collection(Constants.merchantCollection)
          .doc(model.merchantId)
          .collection(Constants.orderDateDocument)
          .doc(dateDocument)
          .collection(Constants.orderSubCollection)
          .doc(model.orderNumber)
          .set(model.toJson())
          .then((value) => log("[MERCHANT] Order added",
              name: "Order Service", time: DateTime.now()));

      ///`Creating Order for CUSTOMER`
      await refMasterOrder
          .doc(Constants.customerCollection)
          .set({"collection": Constants.customerCollection});

      await refMasterOrder
          .doc(Constants.customerCollection)
          .collection(Constants.customerCollection)
          .doc(model.merchantId)
          .set({"customerId": model.customerId});

      await refMasterOrder
          .doc(Constants.customerCollection)
          .collection(Constants.customerCollection)
          .doc(model.customerId)
          .collection(Constants.orderDateDocument)
          .doc(dateDocument)
          .set({"collection": dateDocument});

      await refMasterOrder
          .doc(Constants.customerCollection)
          .collection(Constants.customerCollection)
          .doc(model.customerId)
          .collection(Constants.orderDateDocument)
          .doc(dateDocument)
          .collection(Constants.orderSubCollection)
          .doc(model.orderNumber)
          .set(model.toJson())
          .then((value) => log(
              "[Customer] placed new order added to Order Collection",
              name: "Order Service",
              time: DateTime.now()));

      /// `Adding order Notifications Collection for Merchant`
      await refMerchant
          .doc(model.items.first.merchantId)
          .collection(Constants.notificationsCollection)
          .doc(model.orderNumber)
          .set({"orderId": model.orderNumber}, SetOptions(merge: true))
          .then((value) => log("Notification created for merchant",
              name: "Order Service", time: DateTime.now()))
          .catchError((error) => throw error);

      /// `Adding order Notifications Collection for Merchant`
      await refCustomer
          .doc(model.customerId)
          .collection(Constants.notificationsCollection)
          .doc(model.orderNumber)
          .set({"orderId": model.orderNumber}, SetOptions(merge: true))
          .then((value) => log("Notification created for customer",
              name: "Order Service", time: DateTime.now()))
          .catchError((error) => throw error);

      return true;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  ///UPdating Order
  Future<bool> updateOrder(OrdersModel ordersModel, String merchantId) async {
    CollectionReference refCustomer =
        firestore.collection(UserRole.CUSTOMER.asString());
    CollectionReference refMerchant =
        firestore.collection(UserRole.MERCHANT.asString());

    CollectionReference refMasterOrder =
        firestore.collection(Constants.orderMasterCollection);

    try {
      final dateDocument = ordersModel.createdAt.toString().getYearAndMonth();

      ///`Updating Order for MERCHANT`
      await refMasterOrder
          .doc(Constants.merchantCollection)
          .collection(Constants.merchantCollection)
          .doc(ordersModel.merchantId)
          .collection(Constants.orderDateDocument)
          .doc(dateDocument)
          .collection(Constants.orderSubCollection)
          .doc(ordersModel.orderNumber)
          .update(ordersModel.toJson())
          .then((value) =>
              log("Order Updated in MASTER ORDER Collection for MERCHANT"))
          .catchError((error) => throw error);

      ///`Updating Order for CUSTOMER`
      await refMasterOrder
          .doc(Constants.customerCollection)
          .collection(Constants.customerCollection)
          .doc(ordersModel.customerId)
          .collection(Constants.orderDateDocument)
          .doc(dateDocument)
          .collection(Constants.orderSubCollection)
          .doc(ordersModel.orderNumber)
          .update(ordersModel.toJson())
          .then((value) =>
              log("Order Updated in MASTER ORDER Collection for CUSTOMER"))
          .catchError((error) => throw error);

      /// `Adding order Notifications Collection for Merchant`
      await refMerchant
          .doc(ordersModel.items.first.merchantId)
          .collection(Constants.notificationsCollection)
          .doc(ordersModel.orderNumber)
          .set({"orderId": ordersModel.orderNumber}, SetOptions(merge: true))
          .then((value) => log("Notification created for merchant",
              name: "Order Service", time: DateTime.now()))
          .catchError((error) => throw error);

      /// `Adding order Notifications Collection for Merchant`
      await refCustomer
          .doc(ordersModel.customerId)
          .collection(Constants.notificationsCollection)
          .doc(ordersModel.orderNumber)
          .set({"orderId": ordersModel.orderNumber}, SetOptions(merge: true))
          .then((value) => log("Notification created for customer",
              name: "Order Service", time: DateTime.now()))
          .catchError((error) => throw error);

      return true;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  ///`Cancel Order`
  Future<bool> cancelOrder(OrdersModel ordersModel, String merchantId) async {
    CollectionReference refCustomer =
        firestore.collection(UserRole.CUSTOMER.asString());
    CollectionReference refMerchant =
        firestore.collection(UserRole.MERCHANT.asString());

    CollectionReference refMasterOrder =
        firestore.collection(Constants.orderMasterCollection);

    try {
      final dateDocument = ordersModel.createdAt.toString().getYearAndMonth();

      ///`Cancelling Order for MERCHANT`
      await refMasterOrder
          .doc(Constants.merchantCollection)
          .collection(Constants.merchantCollection)
          .doc(ordersModel.merchantId)
          .collection(Constants.orderDateDocument)
          .doc(dateDocument)
          .collection(Constants.orderSubCollection)
          .doc(ordersModel.orderNumber)
          .update(ordersModel.toJson())
          .then((value) =>
              log("Order cancelled in MASTER ORDER Collection for MERCHANT"))
          .catchError((error) => throw error);

      ///`Cancelling Order for CUSTOMER`
      await refMasterOrder
          .doc(Constants.customerCollection)
          .collection(Constants.customerCollection)
          .doc(ordersModel.customerId)
          .collection(Constants.orderDateDocument)
          .doc(dateDocument)
          .collection(Constants.orderSubCollection)
          .doc(ordersModel.orderNumber)
          .update(ordersModel.toJson())
          .then((value) =>
              log("Order cancelled in MASTER ORDER Collection for CUSTOMER"))
          .catchError((error) => throw error);

      /// `Adding order Notifications Collection for Merchant`
      await refMerchant
          .doc(ordersModel.items.first.merchantId)
          .collection(Constants.notificationsCollection)
          .doc(ordersModel.orderNumber)
          .set({"orderId": ordersModel.orderNumber}, SetOptions(merge: true))
          .then((value) => log("Notification created for merchant",
              name: "Order Service", time: DateTime.now()))
          .catchError((error) => throw error);

      /// `Adding order Notifications Collection for Merchant`
      await refCustomer
          .doc(ordersModel.customerId)
          .collection(Constants.notificationsCollection)
          .doc(ordersModel.orderNumber)
          .set({"orderId": ordersModel.orderNumber}, SetOptions(merge: true))
          .then((value) => log("Notification created for customer",
              name: "Order Service", time: DateTime.now()))
          .catchError((error) => throw error);

      return true;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  ///`Updating Order Status`
  Future<bool> updateOrderStatus(
      OrdersModel ordersModel, String merchantId) async {
    CollectionReference refMasterOrder =
        firestore.collection(Constants.orderMasterCollection);
    CollectionReference refCustomer =
        firestore.collection(UserRole.CUSTOMER.asString());
    CollectionReference refMerchant =
        firestore.collection(UserRole.MERCHANT.asString());

    try {
      final dateDocument = ordersModel.createdAt.toString().getYearAndMonth();
      print("DATE DOC: $dateDocument");

      ///`Updating Order for MERCHANT`
      await refMasterOrder
          .doc(Constants.merchantCollection)
          .collection(Constants.merchantCollection)
          .doc(ordersModel.merchantId)
          .collection(Constants.orderDateDocument)
          .doc(dateDocument)
          .collection(Constants.orderSubCollection)
          .doc(ordersModel.orderNumber)
          .update(ordersModel.toJson())
          .then((value) =>
              log("Order updated in MASTER ORDER Collection for MERCHANT"))
          .catchError((error) => throw error);

      ///`Updating Order for CUSTOMER`
      await refMasterOrder
          .doc(Constants.customerCollection)
          .collection(Constants.customerCollection)
          .doc(ordersModel.customerId)
          .collection(Constants.orderDateDocument)
          .doc(dateDocument)
          .collection(Constants.orderSubCollection)
          .doc(ordersModel.orderNumber)
          .update(ordersModel.toJson())
          .then((value) =>
              log("Order updated in MASTER ORDER Collection for CUSTOMER"))
          .catchError((error) => throw error);

      /// `Adding order Notifications Collection for Merchant`
      await refMerchant
          .doc(ordersModel.items.first.merchantId)
          .collection(Constants.notificationsCollection)
          .doc(ordersModel.orderNumber)
          .set({"orderId": ordersModel.orderNumber}, SetOptions(merge: true))
          .then((value) => log("Notification created for merchant",
              name: "Order Service", time: DateTime.now()))
          .catchError((error) => throw error);

      /// `Adding order Notifications Collection for Merchant`
      await refCustomer
          .doc(ordersModel.customerId)
          .collection(Constants.notificationsCollection)
          .doc(ordersModel.orderNumber)
          .set({"orderId": ordersModel.orderNumber}, SetOptions(merge: true))
          .then((value) => log("Notification created for customer",
              name: "Order Service", time: DateTime.now()))
          .catchError((error) => throw error);

      return true;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<List<OrdersModel>> getOrderDetailsFromID(
      String userId, List<String> orderIds) async {
    CollectionReference refMasterOrder =
        firestore.collection(Constants.orderMasterCollection);
    List<OrdersModel> list = <OrdersModel>[];

    print("GETTING ORDER : $userId");

    try {
      final source = await getSource();
      final dateDocument = DateTime.now().toString().getYearAndMonth();

      for (String orderId in orderIds) {
        await refMasterOrder
            .doc(Constants.customerCollection)
            .collection(Constants.customerCollection)
            .doc(userId)
            .collection(Constants.orderDateDocument)
            .doc(dateDocument)
            .collection(Constants.orderSubCollection)
            .where("orderNumber", isEqualTo: orderId)
            .get(GetOptions(source: source))
            .then((documentSnapshot) async {
          if (documentSnapshot.docs != null &&
              documentSnapshot.docs.isNotEmpty) {
            print('Products exists on the database');

            for (var docSnapshot in documentSnapshot.docs) {
              OrdersModel model = OrdersModel.fromJson(docSnapshot.data());
              list.add(model);
            }
          }
        }).catchError((error) => throw error);
      }

      return list;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }
}
