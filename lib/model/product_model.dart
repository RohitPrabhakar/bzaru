import 'dart:convert';

import 'package:flutter_bzaru/helper/enum.dart';

class ProductModel {
  ProductModel({
    this.id,
    this.merchantId,
    this.title,
    this.description,
    this.price,
    this.size,
    this.imageUrl,
    this.isDeleted = false,
    this.quantity,
    this.tempQty = 0,
    this.mainCategory,
    this.subCategory,
    this.productSize,
    this.inStock,
    this.mrp,
    this.savings,
    this.productSnyonmys,
  });
  String id;
  final String merchantId;
  final String title;
  final String description;
  final double price;
  final String size;
  bool isDeleted;
  List<String> imageUrl;
  int quantity;
  int tempQty;
  final String mainCategory;
  final String subCategory;
  final ProductSize productSize;
  final bool inStock;
  final double mrp;
  final double savings;
  final List<String> productSnyonmys;

  factory ProductModel.fromRawJson(String str) =>
      ProductModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json["id"] == null ? null : json["id"],
        merchantId: json["merchantId"] == null ? null : json["merchantId"],
        title: json["title"] == null ? null : json["title"],
        description: json["description"] == null ? null : json["description"],
        price: json["price"] == null ? null : double.tryParse(json["price"]),
        size: json["size"] == null ? null : json["size"],
        isDeleted: json["isDeleted"] == null ? null : json["isDeleted"],
        imageUrl: json["imageUrl"] == null
            ? null
            : List<String>.from(json["imageUrl"].map((x) => x)),
        quantity: json["quantity"] == null ? null : json["quantity"],
        mainCategory:
            json["mainCategory"] == null ? null : json["mainCategory"],
        subCategory: json["subCategory"] == null ? null : json["subCategory"],
        productSize: json["productSize"] == null
            ? null
            : SizeOfProduct.fromString(json["productSize"]),
        inStock: json["inStock"] == null ? null : json["inStock"],
        savings: json["savings"] == null ? null : json["savings"],
        mrp: json["mrp"] == null ? null : json["mrp"],
        productSnyonmys: json["productSnyonmys"] == null
            ? null
            : List<String>.from(json["productSnyonmys"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "merchantId": merchantId == null ? null : merchantId,
        "title": title == null ? null : title,
        "description": description == null ? null : description,
        "price": price == null ? null : price.toString(),
        "size": size == null ? null : size,
        "isDeleted": isDeleted == null ? null : isDeleted,
        "imageUrl":
            imageUrl == null ? null : List<String>.from(imageUrl.map((x) => x)),
        "quantity": quantity == null ? null : quantity,
        "mainCategory": mainCategory == null ? null : mainCategory,
        "subCategory": subCategory == null ? null : subCategory,
        "productSize": productSize == null ? null : productSize?.asString(),
        "inStock": inStock == null ? null : inStock,
        "savings": savings == null ? null : savings,
        "mrp": mrp == null ? null : mrp,
        "productSnyonmys": productSnyonmys == null
            ? null
            : List<String>.from(productSnyonmys.map((x) => x)),
      };

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is ProductModel &&
        o.merchantId == merchantId &&
        o.title == title &&
        o.description == description &&
        o.price == price &&
        o.size == size &&
        o.mainCategory == mainCategory &&
        o.subCategory == subCategory;
  }

  @override
  int get hashCode {
    return merchantId.hashCode ^
        title.hashCode ^
        description.hashCode ^
        price.hashCode ^
        size.hashCode ^
        mainCategory.hashCode ^
        subCategory.hashCode;
  }

  static List<String> sizeList = [
    ProductSize.KG.asString(),
    ProductSize.MG.asString(),
    ProductSize.G.asString(),
    ProductSize.LTR.asString(),
    ProductSize.ML.asString(),
    ProductSize.PC.asString(),
  ];
}
