import 'car.dart';

class Order {
  final String id;
  final String userId;
  final List<Car> cars;
  final double totalAmount;
  final String status; // 'pending', 'approved', 'shipped'
  final DateTime createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.cars,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  factory Order.fromMap(Map<String, dynamic> map, String id) {
    final carsData = map['cars'] as List<dynamic>;
    final carList = carsData.map((car) => Car.fromMap(car, car['id'])).toList();

    return Order(
      id: id,
      userId: map['userId'] ?? '',
      cars: carList,
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'cars': cars.map((e) => e.toMap()..['id'] = e.id).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
