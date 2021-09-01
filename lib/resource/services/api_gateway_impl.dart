import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bzaru/model/sales_model.dart';
import 'package:flutter_bzaru/model/timing_model.dart';
import 'package:flutter_bzaru/resource/dio_client.dart';
import 'package:flutter_bzaru/resource/services/api_gateway.dart';
import 'package:flutter_bzaru/resource/services/firebase/analytics_service.dart';
import 'package:flutter_bzaru/resource/services/firebase/auth_service.dart';
import 'package:flutter_bzaru/resource/services/firebase/customer_firebase_service.dart';
import 'package:flutter_bzaru/resource/services/firebase/firebase_service.dart';
import 'package:flutter_bzaru/resource/services/firebase/merchant_firebase_Service.dart';
import 'package:flutter_bzaru/resource/services/firebase/order_Service.dart';
import 'package:flutter_bzaru/resource/services/listeners/firebase_listeners.dart';

class ApiGatewayImpl implements ApiGateway {
  final DioClient _dioClient;
  final SharedPrefrenceHelper pref;
  final AuthService authService;
  final FirebaseService firebaseService;
  final OrderService orderService;
  final MerchantFirebaseService merchantFirebaseService;
  final CustomerFirebaseService customerFirebaseService;
  final FirebaseListeners firebaseListeners;
  final AnalyticsService analyticsService;
  ApiGatewayImpl(
    this._dioClient,
    this.pref,
    this.authService,
    this.firebaseService,
    this.merchantFirebaseService,
    this.orderService,
    this.customerFirebaseService,
    this.firebaseListeners,
    this.analyticsService,
  );

  @override
  Future<ProfileModel> login(UserCredential credential) async {
    return await getUserProfile(credential.user.uid, role: UserRole.CUSTOMER);
  }

  @override
  Future<String> register(ProfileModel model) async {
    try {
      return authService.register(model);
    } catch (e) {
      throw e;
    }
  }

  @override
  Future<PhoneAuthCredential> sendOTP(String contact,
      {Future Function(PhoneAuthCredential credential) verificationCompleted,
      Future Function(String verificationId, int resendToken) codeSent,
      Future Function(String verificationId) codeAutoRetrievalTimeout,
      Future Function(FirebaseAuthException e) verificationFailed}) async {
    assert(contact != null && contact.length > 10);
    return authService.sendOTP(contact,
        verificationCompleted: verificationCompleted,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        verificationFailed: verificationFailed);
  }

  @override
  Future<UserCredential> verifyOTP(String verificationId, String smsCode) {
    assert(verificationId != null && smsCode != null);
    return authService.verifyOTP(verificationId, smsCode);
  }

  @override
  Future<String> uploadFile(File file) {
    return firebaseService.uploadFile(file);
  }

  @override
  Future<ProfileModel> getUserProfile(String userId, {UserRole role}) async {
    /// if `userId` is null then fetch logged in user profile
    if (userId == null) {
      userId = await pref.getAccessToken();
    }
    return firebaseService.getUserProfile(userId, role: role);
  }

  @override
  Future<bool> updateProfile(ProfileModel model) async {
    return await firebaseService.updateProfile(model);
  }

  @override
  Future<bool> isUserAvailable(String mobile) async {
    return await authService.isUserAvailable(mobile);
  }

  @override
  Future<List<ProductModel>> getMerchantProductList(String merchantId) async {
    return merchantFirebaseService.getMerchantProductList(merchantId);
  }

  @override
  Future<bool> addNewProduct(ProductModel model) async {
    return merchantFirebaseService.addNewProduct(model);
  }

  @override
  Future<bool> updateMerchantTimings(
      List<TimingModel> timings, String merchantId) {
    return merchantFirebaseService.updateMerchantTimings(timings, merchantId);
  }

  @override
  Future<List<TimingModel>> getMerchantTimings(String merchantId) {
    return merchantFirebaseService.getMerchantTimings(merchantId);
  }

  @override
  Future<String> uploadProductImage(File file, String merchantId) {
    return firebaseService.uploadProductImage(file, merchantId);
  }

  @override
  Future<bool> deleteMerchantProduct(ProductModel model) {
    return merchantFirebaseService.deleteMerchantProduct(model);
  }

  @override
  Future<void> addCollectionListener(String merchantId) {
    return merchantFirebaseService.addCollectionListener(merchantId);
  }

  @override
  Future<void> disposeCollectionListener(String merchantId) {
    return merchantFirebaseService.deleteCollectionListener(merchantId);
  }

  @override
  Future<bool> updateMerchantProduct(ProductModel model) {
    return merchantFirebaseService.updateMerchantProduct(model);
  }

  @override
  Future<bool> placeNewOrder(OrdersModel model) {
    return orderService.placeNewOrder(model);
  }

  @override
  Future<List<OrdersModel>> getOrderList(String userId, UserRole role) {
    return orderService.getOrderList(userId, role);
  }

  @override
  Future<bool> updateOrder(OrdersModel ordersModel, merchantId) {
    return orderService.updateOrder(ordersModel, merchantId);
  }

  @override
  Future<bool> cancelOrder(OrdersModel ordersModel, merchantId) {
    return orderService.cancelOrder(ordersModel, merchantId);
  }

  @override
  Future<bool> updateOrderStatus(OrdersModel ordersModel, merchantId) {
    return orderService.updateOrderStatus(ordersModel, merchantId);
  }

  @override
  Future<List<CustomerListModel>> getCustomersList(String merhcantId) {
    return merchantFirebaseService.getCustomersList(merhcantId);
  }

  @override
  Future<List<OrdersModel>> getMerchantNotifications(String merchantId) {
    return merchantFirebaseService.getMerchantNotifications(merchantId);
  }

  @override
  Future<bool> clearMerchantNotifications(
      String merchantId, bool clearAll, String orderId) {
    return merchantFirebaseService.clearMerchantNotifications(
        merchantId, clearAll, orderId);
  }

  @override
  Future<List<CategoryModel>> getMerchantSubCategories(
      String category, String merchantId) {
    return merchantFirebaseService.getMerchantSubCategories(
        category, merchantId);
  }

  @override
  Future<List<HelpModel>> getHelpArticles() {
    return customerFirebaseService.getHelpArticles();
  }

  @override
  Future<List<Map<String, ProfileModel>>> getCustomerStoreList(
      String customerId) {
    return customerFirebaseService.getCustomerStoreList(customerId);
  }

  @override
  Future<List<ChatMessage>> getChatsForMerchant(String merchantId) {
    return merchantFirebaseService.getChatsForMerchant(merchantId);
  }

  @override
  Future<List<ChatMessage>> getChatsForCustomer(String customerId) {
    return customerFirebaseService.getChatsForCustomer(customerId);
  }

  @override
  Future<List<OrdersModel>> getCustomerNotifications(String customerId) {
    return customerFirebaseService.getCustomerNotifications(customerId);
  }

  @override
  Future<bool> clearCustomerNotifications(
      String customerId, bool clearAll, String orderId) {
    return customerFirebaseService.clearCustomerNotifications(
        customerId, clearAll, orderId);
  }

  @override
  Future<bool> saveCustomerAddress(
      String customerId, List<CustomerAddressModel> savedAddressList) {
    return customerFirebaseService.saveCustomerAddress(
        customerId, savedAddressList);
  }

  @override
  Future<List<CustomerAddressModel>> getCustomerAddress(String customerId) {
    return customerFirebaseService.getCustomerAddress(customerId);
  }

  @override
  Future<bool> deleteCustomerAddress(
      String customerId, CustomerAddressModel model) {
    return customerFirebaseService.deleteCustomerAddress(customerId, model);
  }

  @override
  Future<List<TimingModel>> fetchAvailableTimings(String merchantId) {
    return customerFirebaseService.fetchAvailableTimings(merchantId);
  }

  @override
  Future<List<OrdersModel>> getAvailableProducts(String productTitle) {
    return customerFirebaseService.getAvailableProducts(productTitle);
  }

  @override
  Future<List<ProfileModel>> getSearchedStores(String title) {
    return customerFirebaseService.getSearchedStores(title);
  }

  @override
  StreamSubscription<QuerySnapshot> orderStream(String userId, UserRole role) {
    // TODO: implement orderStream
    throw UnimplementedError();
  }

  @override
  Future<List<AdsModel>> getAds(List<int> adIds) {
    return customerFirebaseService.getAds(adIds);
  }

  @override
  Future<List<ArticlesModel>> getCustomerArticles(List<int> articleIds) {
    return customerFirebaseService.getCustomerArticles(articleIds);
  }

  @override
  Future<List<ArticlesModel>> getMerchantArticles(List<int> articleIds) {
    return merchantFirebaseService.getMerchantArticles(articleIds);
  }

  @override
  Future<List<Sales>> getSalesDashboard(String merchantId, int forMonths) {
    return analyticsService.getSalesDashboard(merchantId, forMonths);
  }

  @override
  Future<List<BProdSalesModel>> getProductsByCount(String merchantId) {
    return analyticsService.getProductsByCount(merchantId);
  }

  @override
  Future<List<BProdSalesModel>> getProductBySales(String merchantId) {
    return analyticsService.getProductBySales(merchantId);
  }

  @override
  Future<List<CustomerCount>> getCustomersListAnalytics(String merhcantId) {
    return analyticsService.getCustomersListAnalytics(merhcantId);
  }

  @override
  Future<List<OrdersModel>> getOrderDetailsFromID(
      String userId, List<String> orderIds) {
    return orderService.getOrderDetailsFromID(userId, orderIds);
  }

  @override
  Future<ChatMessage> getChatWithStore(
      String customerId, String forMerchantId) {
    return customerFirebaseService.getChatWithStore(customerId, forMerchantId);
  }
}
