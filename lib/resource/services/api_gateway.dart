import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/model/ads_model.dart';
import 'package:flutter_bzaru/model/articles_model.dart';
import 'package:flutter_bzaru/model/b_dashboard_models.dart';
import 'package:flutter_bzaru/model/category_model.dart';
import 'package:flutter_bzaru/model/chat_message_model.dart';
import 'package:flutter_bzaru/model/customer_address_model.dart';
import 'package:flutter_bzaru/model/customer_list_model.dart';
import 'package:flutter_bzaru/model/help_model.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/model/sales_model.dart';
import 'package:flutter_bzaru/model/timing_model.dart';

abstract class ApiGateway {
  Future<bool> isUserAvailable(String mobile);
  Future<ProfileModel> login(UserCredential credential);
  Future<UserCredential> verifyOTP(String verificationId, String smsCode);
  Future<String> register(ProfileModel model);
  Future<PhoneAuthCredential> sendOTP(String contact,
      {Future Function(PhoneAuthCredential credential) verificationCompleted,
      Future Function(String verificationId, int resendToken) codeSent,
      Future Function(String verificationId) codeAutoRetrievalTimeout,
      Future Function(FirebaseAuthException e) verificationFailed});
  Future<String> uploadFile(File file);
  Future<ProfileModel> getUserProfile(String userId, {UserRole role});
  Future<bool> updateProfile(ProfileModel model);
  Future<List<ProductModel>> getMerchantProductList(String merchantId);
  Future<bool> addNewProduct(ProductModel model);
  Future<bool> updateMerchantTimings(
      List<TimingModel> timings, String merchantId);
  Future<List<TimingModel>> getMerchantTimings(String merchantId);
  Future<String> uploadProductImage(File file, String merchantId);
  Future<bool> deleteMerchantProduct(ProductModel model);
  Future<bool> updateMerchantProduct(ProductModel model);
  Future<void> addCollectionListener(String merchantId);
  Future<void> disposeCollectionListener(String merchantId);
  Future<bool> placeNewOrder(OrdersModel model);
  Future<List<OrdersModel>> getOrderList(String userId, UserRole role);
  Future<bool> updateOrder(OrdersModel ordersModel, String merchantId);
  Future<bool> cancelOrder(OrdersModel ordersModel, String merchantId);
  Future<bool> updateOrderStatus(OrdersModel ordersModel, String merchantId);
  Future<List<CustomerListModel>> getCustomersList(String merhcantId);
  Future<List<OrdersModel>> getMerchantNotifications(String merchantId);
  Future<bool> clearMerchantNotifications(
      String merchantId, bool clearAll, String orderId);
  Future<List<CategoryModel>> getMerchantSubCategories(
      String category, String merchantId);
  Future<List<HelpModel>> getHelpArticles();
  Future<List<Map<String, ProfileModel>>> getCustomerStoreList(
      String customerId);
  Future<List<ChatMessage>> getChatsForMerchant(String merchantId);
  Future<List<ChatMessage>> getChatsForCustomer(String customerId);
  Future<List<OrdersModel>> getCustomerNotifications(String customerId);
  Future<bool> clearCustomerNotifications(
      String customerId, bool clearAll, String orderId);
  Future<bool> saveCustomerAddress(
      String customerId, List<CustomerAddressModel> savedAddressList);
  Future<List<CustomerAddressModel>> getCustomerAddress(String customerId);
  Future<bool> deleteCustomerAddress(
      String customerId, CustomerAddressModel model);
  Future<List<TimingModel>> fetchAvailableTimings(String merchantId);
  Future<List<OrdersModel>> getAvailableProducts(String productTitle);
  Future<List<ProfileModel>> getSearchedStores(String title);
  StreamSubscription<QuerySnapshot> orderStream(String userId, UserRole role);
  Future<List<ArticlesModel>> getMerchantArticles(List<int> articleIds);
  Future<List<ArticlesModel>> getCustomerArticles(List<int> articleIds);
  Future<List<AdsModel>> getAds(List<int> adIds);
  Future<List<Sales>> getSalesDashboard(String merchantId, int forMonths);
  Future<List<BProdSalesModel>> getProductsByCount(String merchantId);
  Future<List<BProdSalesModel>> getProductBySales(String merchantId);
  Future<List<CustomerCount>> getCustomersListAnalytics(String merhcantId);
  Future<List<OrdersModel>> getOrderDetailsFromID(
      String userId, List<String> orderIds);
  Future<ChatMessage> getChatWithStore(
      String customerId, String forMerchantId);
}
