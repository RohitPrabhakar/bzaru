import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/model/timing_model.dart';
import 'package:flutter_bzaru/ui/pages/personal/checkout/widgets/delivery_time_slot_selection.dart';

class OrdersModel {
  OrdersModel({
    this.id,
    this.orderNumber,
    this.totalAmount,
    this.totalItems,
    this.orderStatus,
    this.address,
    this.customerContact,
    this.customerId,
    this.items,
    this.createdAt,
    this.closedAt,
    this.customerName,
    this.orderMode,
    this.merchantId,
    this.customerProfileImage,
    this.discount,
    this.customerEmail,
    this.updatedOn,
    this.merchantName,
    this.merchantImage,
    this.instructions,
    this.orderDeliveryDate,
    this.timeSlot,
    this.date,
    this.merchantCoverImage,
    this.categoryOfBusiness,
    this.merchantContact,
    this.mainCustomerName,
  });

  String id;
  final String orderNumber;
  final double totalAmount;
  final double discount;
  final int totalItems;
  OrderStatus orderStatus;
  final String customerName;
  final String mainCustomerName;
  final String address;
  final String customerContact;
  final String customerId;
  final String merchantId;
  final DateTime createdAt;
  final DateTime closedAt;
  DateTime orderDeliveryDate;
  final List<ProductModel> items;
  ModeOfOrder orderMode;
  final String customerEmail;
  final String merchantName;
  final String merchantCoverImage;
  final String categoryOfBusiness;
  final String merchantContact;
  String instructions;
  String merchantImage;
  String customerProfileImage;
  DateTime updatedOn;
  TimingModel timeSlot;
  DateModel date;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'totalAmount': totalAmount.toString(),
      'totalItems': totalItems,
      'orderStatus': orderStatus?.asString(),
      'customerName': customerName,
      'address': address,
      'customerContact': customerContact,
      'customerId': customerId,
      'items': items?.map((x) => x?.toJson())?.toList(),
      'closedAt': closedAt == null ? null : closedAt.toIso8601String(),
      "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
      "orderMode": orderMode?.asString(),
      "merchantId": merchantId,
      "customerProfileImage": customerProfileImage,
      'discount': discount.toString(),
      'customerEmail': customerEmail,
      'updatedOn': updatedOn == null ? null : updatedOn.toIso8601String(),
      'merchantName': merchantName,
      'merchantImage': merchantImage,
      "instructions": instructions,
      "orderDeliveryDate": orderDeliveryDate == null
          ? null
          : orderDeliveryDate.toIso8601String(),
      "timeSlot": timeSlot == null ? null : timeSlot.toJson(),
      "merchantContact": merchantContact == null ? null : merchantContact,
      "mainCustomerName": mainCustomerName == null ? null : mainCustomerName,
    };
  }

  factory OrdersModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;

    return OrdersModel(
      id: json["id"] == null ? null : json["id"],
      orderNumber: json["orderNumber"] == null ? null : json['orderNumber'],
      totalAmount: json["totalAmount"] == null
          ? null
          : double.tryParse(json["totalAmount"]),
      totalItems: json["totalItems"] == null ? null : json['totalItems'],
      orderStatus: json["orderStatus"] == null
          ? null
          : _orderFromString(json['orderStatus']),
      address: json["address"] == null ? null : json['address'],
      customerContact:
          json["customerContact"] == null ? null : json['customerContact'],
      customerId: json["customerId"] == null ? null : json['customerId'],
      merchantId: json["merchantId"] == null ? null : json['merchantId'],
      items: json["items"] == null
          ? null
          : List<ProductModel>.from(
              json['items']?.map((x) => ProductModel.fromJson(x))),
      createdAt:
          json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
      closedAt:
          json["closedAt"] == null ? null : DateTime.parse(json["closedAt"]),
      orderDeliveryDate: json["orderDeliveryDate"] == null
          ? null
          : DateTime.parse(json["orderDeliveryDate"]),
      customerName: json["customerName"] == null ? null : json["customerName"],
      orderMode: json["orderMode"] == null
          ? null
          : _modeOfOrderFromString(json["orderMode"]),
      customerProfileImage: json["customerProfileImage"] == null
          ? null
          : json["customerProfileImage"],
      discount:
          json["discount"] == null ? null : double.tryParse(json["discount"]),
      customerEmail:
          json["customerEmail"] == null ? null : json["customerEmail"],
      updatedOn:
          json["updatedOn"] == null ? null : DateTime.parse(json["updatedOn"]),
      merchantName: json["merchantName"] == null ? null : json["merchantName"],
      merchantImage:
          json["merchantImage"] == null ? null : json["merchantImage"],
      instructions: json["instructions"] == null ? null : json["instructions"],
      timeSlot: json["timeSlot"] == null
          ? null
          : TimingModel.fromJson(json["timeSlot"]),
      merchantContact:
          json["merchantContact"] == null ? null : json["merchantContact"],
      mainCustomerName:
          json["mainCustomerName"] == null ? null : json["mainCustomerName"],
    );
  }

  OrdersModel copyWith({
    String orderNumber,
    double totalAmount,
    int totalItems,
    OrderStatus orderStatus,
    String address,
    String customerContact,
    String customerId,
    String customerName,
    List<ProductModel> items,
    ModeOfOrder orderMode,
    String merchantId,
    String customerProfileImage,
    double discount,
    DateTime createdAt,
    DateTime closedAt,
    DateTime orderDeliveryDate,
    String customerEmail,
    DateTime updatedOn,
    String merchantName,
    String merchantImage,
    String instructions,
    TimingModel timeSlot,
    String merchantContact,
    String mainCustomerName,
  }) {
    return OrdersModel(
      orderNumber: orderNumber ?? this.orderNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      totalItems: totalItems ?? this.totalItems,
      orderStatus: orderStatus ?? this.orderStatus,
      address: address ?? this.address,
      customerContact: customerContact ?? this.customerContact,
      customerId: customerId ?? this.customerId,
      items: items ?? this.items,
      customerName: customerName ?? this.customerName,
      orderMode: orderMode ?? this.orderMode,
      merchantId: merchantId ?? this.merchantId,
      customerProfileImage: customerProfileImage ?? this.customerProfileImage,
      discount: discount ?? this.discount,
      createdAt: createdAt ?? this.createdAt,
      closedAt: closedAt ?? this.closedAt,
      customerEmail: customerEmail ?? this.customerEmail,
      updatedOn: updatedOn ?? this.updatedOn,
      merchantName: merchantName ?? this.merchantName,
      merchantImage: merchantImage ?? this.merchantImage,
      instructions: instructions ?? this.instructions,
      orderDeliveryDate: orderDeliveryDate ?? this.orderDeliveryDate,
      timeSlot: timeSlot ?? this.timeSlot,
      merchantContact: merchantContact ?? this.merchantContact,
      mainCustomerName: mainCustomerName ?? this.mainCustomerName,
    );
  }

  @override
  String toString() {
    return 'OrdersModel(orderNumber: $orderNumber, totalAmount: $totalAmount, totalItems: $totalItems, orderStatus: $orderStatus, address: $address, customerContact: $customerContact, customerId: $customerId, items: $items, customerName: $customerName, orderMode: $orderMode, merchantId: $merchantId, customerProfileImage: $customerProfileImage, discount: $discount, createdAt: $createdAt, closedAt: $closedAt, customerEmail: $customerEmail, updatedOn: $updatedOn, merhantName: $merchantName, merchantImage: $merchantImage, instructions: $instructions, orderDeliveryDate: $orderDeliveryDate, timeSlot: $timeSlot)';
  }

  static OrderStatus _orderFromString(String value) {
    switch (value) {
      case "placed":
        return OrderStatus.PLACED;
      case "accepted":
        return OrderStatus.ACCEPTED;
      case "cancelled":
        return OrderStatus.CANCEL;
      case "complete":
        return OrderStatus.COMPLETE;
      case "out for delivery":
        return OrderStatus.DELIVERY;
      case "packed":
        return OrderStatus.PACKED;
      case "packing":
        return OrderStatus.PACKING;
      case "recieved":
        return OrderStatus.RECIEVED;
      case "ready for pickup":
        return OrderStatus.PICKUP;

      default:
        return null;
    }
  }

  static ModeOfOrder _modeOfOrderFromString(String value) {
    switch (value) {
      case "pickup":
        return ModeOfOrder.PICKUP;
      case "delivery":
        return ModeOfOrder.DELIVERY;
      default:
        return null;
    }
  }

  static int valueFromOrderStatus(OrderStatus orderStatus) {
    switch (orderStatus) {
      case OrderStatus.ACCEPTED:
        return 0;
      case OrderStatus.RECIEVED:
        return 1;
      case OrderStatus.PACKING:
        return 2;
      case OrderStatus.PACKED:
        return 3;
      case OrderStatus.DELIVERY:
        return 4;
      case OrderStatus.COMPLETE:
        return 5;
      case OrderStatus.PICKUP:
        return 6;
      default:
        return null;
    }
  }
}
