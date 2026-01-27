import '../../data/models/order_model.dart';
import '../repositories/order_repository.dart';

class PlaceOrderUseCase {
  final OrderRepository repo;
  const PlaceOrderUseCase(this.repo);

  Future<String> call(OrderModel order) => repo.placeOrder(order);
}
