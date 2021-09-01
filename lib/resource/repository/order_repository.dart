import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/resource/services/api_gateway.dart';
import 'package:flutter_bzaru/resource/session/session_service.dart';

class OrderRepository {
  final ApiGateway apiGatway;
  final SessionService session;
  OrderRepository(this.apiGatway, this.session);

  Future<bool> placeNewOrder(OrdersModel model) {
    return apiGatway.placeNewOrder(model);
  }

  Future<List<OrdersModel>> getOrderList(String userId, UserRole role) {
    return apiGatway.getOrderList(userId, role);
  }

  Future<bool> updateOrder(OrdersModel ordersModel, String merchantId) {
    return apiGatway.updateOrder(ordersModel, merchantId);
  }

  Future<bool> cancelOrder(OrdersModel ordersModel, String merchantId) {
    return apiGatway.cancelOrder(ordersModel, merchantId);
  }

  Future<bool> updateOrderStatus(OrdersModel ordersModel, String merchantId) {
    return apiGatway.updateOrderStatus(ordersModel, merchantId);
  }

  Future<List<OrdersModel>> getOrderDetailsFromID(
      String userId, List<String> orderIds) {
    return apiGatway.getOrderDetailsFromID(userId, orderIds);
  }
}
