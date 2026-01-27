import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'data/datasources/order_remote_datasource.dart';
import 'data/repositories/order_repository_impl.dart';
import 'domain/usecases/place_order.dart';

class OrderDI {
  static PlaceOrderUseCase placeOrderUseCase() {
    final remote = OrderRemoteDataSource(
      db: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
    final repo = OrderRepositoryImpl(remote);
    return PlaceOrderUseCase(repo);
  }
}
