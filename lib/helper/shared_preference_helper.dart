import 'dart:convert';

import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefrenceHelper {
  SharedPrefrenceHelper._internal();
  static final SharedPrefrenceHelper _singleton =
      SharedPrefrenceHelper._internal();

  factory SharedPrefrenceHelper() {
    return _singleton;
  }

  Future<String> getLanguageCode() async {
    return (await SharedPreferences.getInstance())
        .getString(UserPreferenceKey.LanguageCode.toString());
  }

  Future<bool> setLanguageCode(String value) async {
    return (await SharedPreferences.getInstance())
        .setString(UserPreferenceKey.LanguageCode.toString(), value);
  }

  Future<bool> setPrimaryProfile(String userRole) async {
    return (await SharedPreferences.getInstance())
        .setString(UserPreferenceKey.PrimaryRole.toString(), userRole);
  }

  Future<void> saveProfile(ProfileModel user) async {
    return (await SharedPreferences.getInstance()).setString(
        UserPreferenceKey.UserProfile.toString(), json.encode(user.toJson()));
  }

  Future<bool> setAccessToken(String value) async {
    return (await SharedPreferences.getInstance())
        .setString(UserPreferenceKey.AccesssToken.toString(), value);
  }

  Future<String> getAccessToken() async {
    return (await SharedPreferences.getInstance())
        .getString(UserPreferenceKey.AccesssToken.toString());
  }

  Future<String> getPrimaryProfile() async {
    return (await SharedPreferences.getInstance())
        .getString(UserPreferenceKey.PrimaryRole.toString());
  }

  Future<ProfileModel> getUserProfile() async {
    final jsonString = (await SharedPreferences.getInstance())
        .getString(UserPreferenceKey.UserProfile.toString());
    return ProfileModel.fromJson(json.decode(jsonString));
  }

  Future<bool> clearAll() async {
    return (await SharedPreferences.getInstance()).clear();
  }

  Future<bool> setRecentSearches(List<String> recentSearches) async {
    return (await SharedPreferences.getInstance()).setStringList(
        UserPreferenceKey.RecentSearch.toString(), recentSearches);
  }

  Future<List<String>> getRecentSearches() async {
    final List<String> listOfRecentSearches =
        (await SharedPreferences.getInstance())
            .getStringList(UserPreferenceKey.RecentSearch.toString());
    return listOfRecentSearches;
  }

  Future<bool> clearRecentSearches() async {
    return (await SharedPreferences.getInstance())
        .remove(UserPreferenceKey.RecentSearch.toString());
  }

  Future<int> getOrderLength() async {
    return (await SharedPreferences.getInstance())
        .getInt(UserPreferenceKey.OrderLength.toString());
  }

  Future<bool> setOrderLength(int value) async {
    return (await SharedPreferences.getInstance())
        .setInt(UserPreferenceKey.OrderLength.toString(), value);
  }

  Future<int> getMessageLength() async {
    return (await SharedPreferences.getInstance())
        .getInt(UserPreferenceKey.MessageLength.toString());
  }

  Future<bool> setMessageLength(int value) async {
    return (await SharedPreferences.getInstance())
        .setInt(UserPreferenceKey.MessageLength.toString(), value);
  }

  Future<int> getMerchantNotifLen() async {
    return (await SharedPreferences.getInstance())
        .getInt(UserPreferenceKey.MerchantNotifLen.toString());
  }

  Future<bool> setMerchantNotifLen(int value) async {
    return (await SharedPreferences.getInstance())
        .setInt(UserPreferenceKey.MerchantNotifLen.toString(), value);
  }

  Future<int> getCustomerNotifLen() async {
    return (await SharedPreferences.getInstance())
        .getInt(UserPreferenceKey.CustomerNotifLen.toString());
  }

  Future<bool> setCustomerNotifLen(int value) async {
    return (await SharedPreferences.getInstance())
        .setInt(UserPreferenceKey.CustomerNotifLen.toString(), value);
  }

  Future<bool> setCustomerCart(List<OrdersModel> myCart) async {
    List<String> list = [];
    myCart.forEach((element) {
      list.add(json.encode(element.toJson()));
    });

    return (await SharedPreferences.getInstance())
        .setString(UserPreferenceKey.CustomerCart.toString(), list.toString());
  }

  Future<List<OrdersModel>> getCustomerCart() async {
    List<OrdersModel> myCart = [];

    final list = (await SharedPreferences.getInstance())
        .getString(UserPreferenceKey.CustomerCart.toString());
    if (list != null && list.isNotEmpty) {
      final data = json.decode(list);

      data.forEach((element) {
        myCart.add(OrdersModel.fromJson(element));
      });
    }
    return myCart;
  }

  Future<bool> clearCart() async {
    return (await SharedPreferences.getInstance())
        .setString(UserPreferenceKey.CustomerCart.toString(), "");
  }

  Future<bool> setAddedProductsToCart(List<ProductModel> addedProducts) async {
    List<String> list = [];

    addedProducts.forEach((element) {
      list.add(json.encode(element.toJson()));
    });
    return (await SharedPreferences.getInstance()).setString(
        UserPreferenceKey.AddedProductsCart.toString(), list.toString());
  }

  Future<List<ProductModel>> getAddedProductsToCart() async {
    List<ProductModel> addedProductsCart = [];

    final list = (await SharedPreferences.getInstance())
        .getString(UserPreferenceKey.AddedProductsCart.toString());
    if (list != null && list.isNotEmpty) {
      final data = json.decode(list);

      data.forEach((element) {
        addedProductsCart.add(ProductModel.fromJson(element));
      });
    }
    return addedProductsCart;
  }

  Future<bool> clearAddedProducts() async {
    return (await SharedPreferences.getInstance())
        .setString(UserPreferenceKey.AddedProductsCart.toString(), "");
  }
}

enum UserPreferenceKey {
  LanguageCode,
  CountryISOCode,
  UserProfile,
  AccesssToken,
  PrimaryRole,
  RecentSearch,
  OrderLength,
  MessageLength,
  MerchantNotifLen,
  CustomerNotifLen,
  CustomerCart,
  AddedProductsCart,
}
