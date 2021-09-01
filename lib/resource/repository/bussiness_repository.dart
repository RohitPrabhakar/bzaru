import 'dart:io';

import 'package:flutter_bzaru/model/articles_model.dart';
import 'package:flutter_bzaru/model/b_dashboard_models.dart';
import 'package:flutter_bzaru/model/category_model.dart';
import 'package:flutter_bzaru/model/chat_message_model.dart';
import 'package:flutter_bzaru/model/customer_list_model.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/model/sales_model.dart';
import 'package:flutter_bzaru/model/timing_model.dart';
import 'package:flutter_bzaru/resource/services/api_gateway.dart';
import 'package:flutter_bzaru/resource/session/session_service.dart';

class BussinessRepository {
  final ApiGateway apiGatway;
  final SessionService session;
  BussinessRepository(this.apiGatway, this.session);

  Future<List<ProductModel>> getMerchantProductList(String merchantId) {
    return apiGatway.getMerchantProductList(merchantId);
  }

  Future<bool> addNewProduct(ProductModel model) {
    return apiGatway.addNewProduct(model);
  }

  Future<bool> updateMerchantTimings(
      List<TimingModel> timings, String merchantId) {
    return apiGatway.updateMerchantTimings(timings, merchantId);
  }

  Future<List<TimingModel>> getMerchantTimings(String merchantId) {
    return apiGatway.getMerchantTimings(merchantId);
  }

  Future<String> uploadProductImage(File file, String merchantId) async {
    return await apiGatway.uploadProductImage(file, merchantId);
  }

  Future<bool> deleteMerchantProduct(String merchantId, ProductModel model) {
    return apiGatway.deleteMerchantProduct(model);
  }

  Future<void> addCollectionListener(String merchantId) {
    return apiGatway.addCollectionListener(merchantId);
  }

  Future<void> disposeCollectionListener(String merchantId) {
    return apiGatway.disposeCollectionListener(merchantId);
  }

  Future<bool> updateMerchantProduct(ProductModel model) {
    return apiGatway.updateMerchantProduct(model);
  }

  Future<List<CustomerListModel>> getCustomersList(String merhcantId) {
    return apiGatway.getCustomersList(merhcantId);
  }

  Future<List<OrdersModel>> getMerchantNotifications(String merchantId) {
    return apiGatway.getMerchantNotifications(merchantId);
  }

  Future<bool> clearMerchantNotifications(
      String merchantId, bool clearAll, String orderId) {
    return apiGatway.clearMerchantNotifications(merchantId, clearAll, orderId);
  }

  Future<List<CategoryModel>> getMerchantSubCategories(
      String category, String merchantId) {
    return apiGatway.getMerchantSubCategories(category, merchantId);
  }

  Future<List<ChatMessage>> getChatsForMerchant(String merchantId) {
    return apiGatway.getChatsForMerchant(merchantId);
  }

  Future<List<ArticlesModel>> getMerchantArticles(List<int> articleIds) {
    return apiGatway.getMerchantArticles(articleIds);
  }

  Future<List<Sales>> getSalesDashboard(String merchantId, int forMonths) {
    return apiGatway.getSalesDashboard(merchantId, forMonths);
  }

  Future<List<BProdSalesModel>> getProductsByCount(String merchantId) {
    return apiGatway.getProductsByCount(merchantId);
  }

  Future<List<BProdSalesModel>> getProductBySales(String merchantId) {
    return apiGatway.getProductBySales(merchantId);
  }

  Future<List<CustomerCount>> getCustomersListAnalytics(String merchantId) {
    return apiGatway.getCustomersListAnalytics(merchantId);
  }
}
