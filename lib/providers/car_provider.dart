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
      notifyListeners();
    } catch (e) {
      print("❌ Lỗi fetchCars: $e");
    }
  }

  /// ➕ Thêm xe mới
  Future<void> addCar(Car car) async {
    try {
      final docRef = await _firestore.collection('cars').add(car.toMap());
      _cars.insert(0, car.copyWith(id: docRef.id));
      notifyListeners();
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
    } catch (e) {
      print("❌ Lỗi deleteCar: $e");
    }
  }
}
