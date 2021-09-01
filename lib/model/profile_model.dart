import 'dart:convert';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/model/DeliveryAddress.dart';
import 'package:flutter_bzaru/model/customer_address_model.dart';
import 'package:flutter_bzaru/model/timing_model.dart';

class ProfileModel {
  ProfileModel(
      {this.id,
      this.avatar,
      // this.firstName,
      // this.lastName,
      this.email,
      this.contactPrimary,
      this.createdAt,
      this.name,
      this.categoryOfBusiness,
      this.profileImage,
      this.coverImage,
      this.description,
      this.businessPhoneNumber,
      this.businessEmail,
      this.address1,
      this.address2,
      this.city,
      this.state,
      this.pinCode,
      this.aadharImageLink,
      this.businessLicenseImage,
      this.timings,
      this.role,
      this.activityStatus,
      this.isPaidCustomer,
      this.maxItems,
      this.maxProductImages,
      this.articles,
      this.ads,
      this.lastLogin,
      this.lastLogout,
      this.accountLoggedOut,
      this.customerAddress,
      this.deliveryAddress});

  String id;
  String avatar;
  final String email;
  final String contactPrimary;
  final DateTime createdAt;
  final String name;
  final String categoryOfBusiness;
  final String profileImage;
  String coverImage;
  final String description;
  final String businessPhoneNumber;
  final String businessEmail;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String pinCode;
  final String aadharImageLink;
  final String businessLicenseImage;
  final List<TimingModel> timings;
  final UserRole role;
  final UserActivityStatus activityStatus;
  final bool isPaidCustomer;
  final int maxItems;
  final int maxProductImages;
  final List<int> articles;
  final List<int> ads;
  final String lastLogin;
  final String lastLogout;
  final bool accountLoggedOut;
  final List<CustomerAddressModel> customerAddress;
  final List<DeliveryAddress> deliveryAddress;

  factory ProfileModel.fromRawJson(String str) =>
      ProfileModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json["id"] == null ? null : json["id"],
        avatar: json["avatar"] == null ? null : json["avatar"],
        // firstName: json["firstName"] == null ? null : json["firstName"],
        // lastName: json["lastName"] == null ? null : json["lastName"],
        email: json["email"] == null ? null : json["email"],
        contactPrimary:
            json["contactPrimary"] == null ? null : json["contactPrimary"],

        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        name: json["name"] == null ? null : json["name"],
        categoryOfBusiness: json["categoryOfBusiness"] == null
            ? null
            : json["categoryOfBusiness"],
        profileImage:
            json["profileImage"] == null ? null : json["profileImage"],
        coverImage: json["coverImage"] == null ? null : json["coverImage"],
        description: json["description"] == null ? null : json["description"],
        businessPhoneNumber: json["businessPhoneNumber"] == null
            ? null
            : json["businessPhoneNumber"],
        businessEmail:
            json["businessEmail"] == null ? null : json["businessEmail"],
        address1: json["address1"] == null ? null : json["address1"],
        address2: json["address2"] == null ? null : json["address2"],
        city: json["city"] == null ? null : json["city"],
        state: json["state"] == null ? null : json["state"],
        pinCode: json["pinCode"] == null ? null : json["pinCode"],
        aadharImageLink:
            json["aadharImageLink"] == null ? null : json["aadharImageLink"],
        businessLicenseImage: json["businessLicenseImage"] == null
            ? null
            : json["businessLicenseImage"],
        timings: json["timings"] == null
            ? null
            : List<TimingModel>.from(
                json["timings"].map((x) => TimingModel.fromJson(x))),
        role: json["role"] == null
            ? null
            : json["role"] == UserRole.CUSTOMER.asString()
                ? UserRole.CUSTOMER
                : UserRole.MERCHANT,
        activityStatus: json["activityStatus"] == null
            ? null
            : _activityStatusFromString(json["activityStatus"]),
        maxItems: json["maxItems"] == null ? null : json["maxItems"],
        isPaidCustomer:
            json["isPaidCustomer"] == null ? null : json["isPaidCustomer"],
        maxProductImages:
            json["maxProductImages"] == null ? null : json["maxProductImages"],
        articles:
            json["articles"] == null ? null : List<int>.from(json["articles"]),
        ads: json["ads"] == null ? null : List<int>.from(json["ads"]),
        lastLogout: json["lastLogout"] == null ? null : json["lastLogout"],
        lastLogin: json["lastLogin"] == null ? null : json["lastLogin"],
        accountLoggedOut:
            json["accountLoggedOut"] == null ? null : json["accountLoggedOut"],



    customerAddress: json["customerAddress"] == null
        ? null
        : List<CustomerAddressModel>.from(
        json["customerAddress"].map((x) => CustomerAddressModel.fromJson(x))),
    deliveryAddress: json["deliveryAddress"] == null
        ? null
        : List<DeliveryAddress>.from(
        json["deliveryAddress"].map((x) => DeliveryAddress.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "avatar": avatar == null ? null : avatar,
        // "firstName": firstName == null ? null : firstName,
        // "lastName": lastName == null ? null : lastName,
        "email": email == null ? null : email,
        "contactPrimary": contactPrimary == null ? null : contactPrimary,
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
        "name": name == null ? null : name,
        "categoryOfBusiness":
            categoryOfBusiness == null ? null : categoryOfBusiness,
        "profileImage": profileImage == null ? null : profileImage,
        "coverImage": coverImage == null ? null : coverImage,
        "description": description == null ? null : description,
        "businessPhoneNumber":
            businessPhoneNumber == null ? null : businessPhoneNumber,
        "businessEmail": businessEmail == null ? null : businessEmail,
        "address1": address1 == null ? null : address1,
        "address2": address2 == null ? null : address2,
        "city": city == null ? null : city,
        "state": state == null ? null : state,
        "pinCode": pinCode == null ? null : pinCode,
        "aadharImageLink": aadharImageLink == null ? null : aadharImageLink,
        "businessLicenseImage":
            businessLicenseImage == null ? null : businessLicenseImage,
        "timings": timings == null
            ? null
            : List<dynamic>.from(timings.map((x) => x.toJson())),
        "role": role == null ? null : role.asString(),
        "activityStatus":
            activityStatus == null ? null : activityStatus.asString(),
        "maxItems": maxItems == null ? null : maxItems,
        "isPaidCustomer": isPaidCustomer == null ? null : isPaidCustomer,
        "maxProductImages": maxProductImages == null ? null : maxProductImages,
        "articles": articles == null ? null : articles,
        "ads": ads == null ? null : ads,
        "lastLogout": lastLogout == null ? null : lastLogout,
        "lastLogin": lastLogin == null ? null : lastLogin,
        "accountLoggedOut": accountLoggedOut == null ? null : accountLoggedOut,
        "customerAddress": customerAddress == null ? null : List<dynamic>.from(customerAddress.map((e) => e.toJson())),
        "deliveryAddress": deliveryAddress == null ? null : List<dynamic>.from(deliveryAddress.map((e) => e.toJson())),
      };

  ProfileModel copyWith({
    String id,
    String description,
    DateTime createdAt,
    String avatar,
    String email,
    String contactPrimary,
    String contactSecondary,
    String name,
    String categoryOfBusiness,
    String profileImage,
    String coverImage,
    String phoneNumber,
    String businessPhoneNumber,
    String businessEmail,
    String address1,
    String address2,
    String city,
    String state,
    String pinCode,
    String aadharImageLink,
    String businessLicenseImage,
    List<TimingModel> timings,
    UserRole role,
    String merchantId,
    UserActivityStatus activityStatus,
    bool isPaidCustomer,
    int maxItems,
    int maxProductImages,
    String lastLogin,
    String lastLogout,
    bool accountLoggedOut,
    List<CustomerAddressModel> customerAddress,
    List<DeliveryAddress> deliveryAddress

  }) =>
      ProfileModel(
        id: id ?? this.id,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        aadharImageLink: aadharImageLink ?? this.aadharImageLink,
        address1: address1 ?? this.address1,
        address2: address2 ?? this.address2,
        avatar: avatar ?? this.avatar,
        businessEmail: businessEmail ?? this.businessEmail,
        businessLicenseImage: businessLicenseImage ?? this.businessLicenseImage,
        businessPhoneNumber: businessPhoneNumber ?? this.businessPhoneNumber,
        categoryOfBusiness: categoryOfBusiness ?? this.categoryOfBusiness,
        city: city ?? this.city,
        contactPrimary: contactPrimary ?? this.contactPrimary,
        coverImage: coverImage ?? this.coverImage,
        email: email ?? this.email,
        name: name ?? this.name,
        pinCode: pinCode ?? this.pinCode,
        profileImage: profileImage ?? this.profileImage,
        role: role ?? this.role,
        state: state ?? this.state,
        timings: timings ?? this.timings,
        activityStatus: activityStatus ?? this.activityStatus,
        isPaidCustomer: isPaidCustomer ?? this.isPaidCustomer,
        maxItems: maxItems ?? this.maxItems,
        maxProductImages: maxProductImages ?? this.maxProductImages,
        accountLoggedOut: accountLoggedOut ?? this.accountLoggedOut,
        lastLogin: lastLogin ?? this.lastLogin,
        lastLogout: lastLogout ?? this.lastLogout,
        customerAddress: customerAddress??this.customerAddress,
        deliveryAddress: deliveryAddress??this.deliveryAddress
      );

  static UserActivityStatus _activityStatusFromString(String value) {
    switch (value) {
      case "active":
        return UserActivityStatus.ACTIVE;
      case "inactive":
        return UserActivityStatus.INACTIVE;
      default:
        return null;
    }
  }
}
