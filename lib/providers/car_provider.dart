import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car.dart';

class CarProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  List<Car> _cars = [];

  List<Car> get cars => _cars;

  /// 🔄 Lấy danh sách xe
  Future<void> fetchCars() async {
    try {
      final snapshot = await _firestore
          .collection('cars')
          .orderBy('createdAt', descending: true)
          .get();

      _cars = snapshot.docs
          .map((doc) => Car.fromMap(doc.data(), doc.id))
          .toList();

      print("📦 Đã tải ${_cars.length} xe từ Firestore");
      notifyListeners();
    } catch (e) {
      print("❌ Lỗi fetchCars: $e");
    }
  }

  /// ➕ Thêm xe mới
  Future<void> addCar(Car car) async {
    try {
      // dùng server timestamp để đảm bảo orderBy không lỗi
      final data = car.toMap();
      data['createdAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore.collection('cars').add(data);

      // đọc lại document vừa tạo (để có createdAt thực)
      final newDoc = await docRef.get();
      final newCar = Car.fromMap(newDoc.data()!, docRef.id);

      _cars.insert(0, newCar);
      notifyListeners();
      print("✅ Đã thêm xe ${car.name}");
    } catch (e) {
      print("❌ Lỗi addCar: $e");
    }
  }

  /// ❌ Xoá xe
  Future<void> deleteCar(String carId) async {
    try {
      await _firestore.collection('cars').doc(carId).delete();
      _cars.removeWhere((car) => car.id == carId);
      notifyListeners();
      print("🗑️ Đã xoá xe $carId");
    } catch (e) {
      print("❌ Lỗi deleteCar: $e");
    }
  }
}
