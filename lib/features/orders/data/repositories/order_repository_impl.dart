import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remote;
  const OrderRepositoryImpl(this.remote);

  @override
  Future<String> placeOrder(OrderModel order) => remote.placeOrder(order);
}
