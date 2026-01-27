import '../../data/models/order_model.dart';

abstract class OrderRepository {
  Future<String> placeOrder(OrderModel order);
}
