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

  /// 🔄 Convert từ Map (Firestore) → Car
  factory Car.fromMap(Map<String, dynamic> map, String id) {
    return Car(
      id: id,
      name: map['name'] ?? '',
      brand: map['brand'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// 🔄 Convert từ Car → Map (để lưu Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brand': brand,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 📦 Copy để thay đổi ID sau khi add Firestore
  Car copyWith({String? id}) {
    return Car(
      id: id ?? this.id,
      name: name,
      brand: brand,
      price: price,
      description: description,
      imageUrl: imageUrl,
      createdAt: createdAt,
    );
  }
}
