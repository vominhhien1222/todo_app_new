import 'car.dart';

class CartItem {
  final String id;
  final String userId;
  final Car car;
  final int quantity;

  CartItem({
    required this.id,
    required this.userId,
    required this.car,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'car': car.toMap(),
      'carId': car.id,
      'quantity': quantity,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, String id) {
    return CartItem(
      id: id,
      userId: map['userId'] ?? '',
      car: Car.fromMap(map['car'], map['carId'] ?? ''),
      quantity: map['quantity'] ?? 1,
    );
  }
}
