import 'package:cloud_firestore/cloud_firestore.dart';

class Car {
  final String id;
  final String name;
  final String brand;
  final double price;
  final String description;
  final String imageUrl;
  final DateTime createdAt;

  Car({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
  });

  /// ✅ Map dữ liệu để lưu Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// ✅ Tạo Car từ dữ liệu Firestore
  factory Car.fromMap(Map<String, dynamic> data, String id) {
    final createdRaw = data['createdAt'];
    DateTime createdAt;

    if (createdRaw is Timestamp) {
      createdAt = createdRaw.toDate();
    } else if (createdRaw is String) {
      createdAt = DateTime.tryParse(createdRaw) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return Car(
      id: id,
      name: data['name'] ?? '',
      brand: data['brand'] ?? '',
      price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: createdAt,
    );
  }

  Car copyWith({
    String? id,
    String? name,
    String? brand,
    double? price,
    String? description,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Car(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
