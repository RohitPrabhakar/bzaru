import 'package:flutter_bzaru/model/ads_model.dart';
import 'package:flutter_bzaru/model/articles_model.dart';
import 'package:flutter_bzaru/model/chat_message_model.dart';
import 'package:flutter_bzaru/model/customer_address_model.dart';
import 'package:flutter_bzaru/model/help_model.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/model/timing_model.dart';
import 'package:flutter_bzaru/resource/services/api_gateway.dart';
import 'package:flutter_bzaru/resource/session/session_service.dart';

class CustomerRepository {
  final ApiGateway apiGatway;
  final SessionService session;
  CustomerRepository(this.apiGatway, this.session);

  Future<List<HelpModel>> getHelpArticles() {
    return apiGatway.getHelpArticles();
  }

  Future<List<Map<String, ProfileModel>>> getCustomerStoreList(
      String customerId) {
    return apiGatway.getCustomerStoreList(customerId);
  }

  Future<List<ChatMessage>> getChatsForCustomer(String customerId) {
    return apiGatway.getChatsForCustomer(customerId);
  }

  Future<List<OrdersModel>> getCustomerNotifications(String customerId) {
    return apiGatway.getCustomerNotifications(customerId);
  }

  Future<bool> clearCustomerNotifications(
      String customerId, bool clearAll, String orderId) {
    return apiGatway.clearCustomerNotifications(customerId, clearAll, orderId);
  }

  Future<bool> saveCustomerAddress(
      String customerId, List<CustomerAddressModel> savedAddressList) {
    return apiGatway.saveCustomerAddress(customerId, savedAddressList);
  }

  Future<List<CustomerAddressModel>> getCustomerAddress(String customerId) {
    return apiGatway.getCustomerAddress(customerId);
  }

  Future<bool> deleteCustomerAddress(
      String customerId, CustomerAddressModel model) {
    return apiGatway.deleteCustomerAddress(customerId, model);
  }

  Future<List<TimingModel>> fetchAvailableTimings(String merchantId) {
    return apiGatway.fetchAvailableTimings(merchantId);
  }

  Future<List<OrdersModel>> getAvailableProducts(String productTitle) {
    return apiGatway.getAvailableProducts(productTitle);
  }

  Future<List<ProfileModel>> getSearchedStores(String title) {
    return apiGatway.getSearchedStores(title);
  }

  Future<List<ArticlesModel>> getCustomerArticles(List<int> articleIds) {
    return apiGatway.getCustomerArticles(articleIds);
  }

  Future<List<AdsModel>> getAds(List<int> adIds) {
    return apiGatway.getAds(adIds);
  }

  Future<ChatMessage> getChatWithStore(
      String customerId, String forMerchantId) {
    return apiGatway.getChatWithStore(customerId, forMerchantId);
  }
}
