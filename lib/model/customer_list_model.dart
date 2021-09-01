import 'dart:convert';

class CustomerListModel {
  final String customerId;
  final double totalAmount;
  final int totalOrders;
  final String lastOrderNumber;
  final String customerName;
  final String customerAddress;
  final DateTime lastOrderDate;
  final double lastOrderAmount;
  final String customerProfileImage;
  final String customerEmail;

  CustomerListModel({
    this.customerId,
    this.totalAmount,
    this.totalOrders,
    this.lastOrderNumber,
    this.customerName,
    this.customerAddress,
    this.lastOrderDate,
    this.lastOrderAmount,
    this.customerProfileImage,
    this.customerEmail,
  });

  CustomerListModel copyWith({
    String customerId,
    double totalAmount,
    int totalOrders,
    String lastOrderNumber,
    String customerName,
    String customerAddress,
    DateTime lastOrderDate,
    double lastOrderAmount,
    String customerProfileImage,
    String customerEmail,
  }) {
    return CustomerListModel(
      customerId: customerId ?? this.customerId,
      totalAmount: totalAmount ?? this.totalAmount,
      totalOrders: totalOrders ?? this.totalOrders,
      lastOrderNumber: lastOrderNumber ?? this.lastOrderNumber,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      lastOrderDate: lastOrderDate ?? this.lastOrderDate,
      lastOrderAmount: lastOrderAmount ?? this.lastOrderAmount,
      customerProfileImage: customerProfileImage ?? this.customerProfileImage,
      customerEmail: customerEmail ?? this.customerEmail,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'totalAmount': totalAmount,
      'totalOrders': totalOrders,
      'lastOrderNumber': lastOrderNumber,
      'customerName': customerName,
      'customerAddress': customerAddress,
      'lastOrderDate': lastOrderDate?.millisecondsSinceEpoch,
      'lastOrderAmount': lastOrderAmount,
      'customerProfileImage': customerProfileImage,
      'customerEmail': customerEmail,
    };
  }

  factory CustomerListModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return CustomerListModel(
      customerId: map['customerId'],
      totalAmount: map['totalAmount'],
      totalOrders: map['totalOrders'],
      lastOrderNumber: map['lastOrderNumber'],
      customerName: map['customerName'],
      customerAddress: map['customerAddress'],
      lastOrderDate: DateTime.fromMillisecondsSinceEpoch(map['lastOrderDate']),
      lastOrderAmount: map['lastOrderAmount'],
      customerProfileImage: map['customerProfileImage'],
      customerEmail: map['customerEmail'],
    );
  }

  String toJson() => json.encode(toMap());

  factory CustomerListModel.fromJson(String source) =>
      CustomerListModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CustomerListModel(customerId: $customerId, totalAmount: $totalAmount, totalOrders: $totalOrders, lastOrderNumber: $lastOrderNumber, customerName: $customerName, customerAddress: $customerAddress, lastOrderDate: $lastOrderDate, lastOrderAmount: $lastOrderAmount, customerProfileImage: $customerProfileImage, customerEmail: $customerEmail)';
  }
}
