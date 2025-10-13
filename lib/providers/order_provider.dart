import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as my; // ✅ đặt alias cho model Order
import '../models/car.dart';

class OrderProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  List<my.Order> _orders = []; // dùng my.Order thay vì Order
  List<my.Order> get orders => _orders;

  /// 🔄 Lấy tất cả đơn hàng (cho admin)
  Future<void> fetchAllOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      _orders = snapshot.docs
          .map((doc) => my.Order.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      print("❌ Lỗi fetchAllOrders: $e");
    }
  }

  /// 🔄 Lấy đơn hàng của 1 user (cho user)
  Future<List<my.Order>> fetchOrdersByUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => my.Order.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print("❌ Lỗi fetchOrdersByUser: $e");
      return [];
    }
  }

  /// ➕ Tạo đơn hàng mới (có thông tin người mua)
  Future<void> placeOrder({
    required String userId,
    required List<Car> cars,
    required double totalAmount,
    Map<String, dynamic>? buyerInfo, // ✅ THÊM PARAM NÀY
  }) async {
    try {
      final order = my.Order(
        id: '',
        userId: userId,
        cars: cars,
        totalAmount: totalAmount,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      // ✅ Lưu lên Firestore
      await _firestore.collection('orders').add({
        ...order.toMap(), // giữ nguyên thông tin đơn hàng gốc
        'buyerInfo': buyerInfo, // ✅ thêm thông tin người mua
      });

      notifyListeners();
    } catch (e) {
      print("❌ Lỗi tạo đơn hàng: $e");
    }
  }

  /// ✅ Admin cập nhật trạng thái đơn hàng
  Future<void> updateStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
    } catch (e) {
      print("❌ Lỗi updateStatus: $e");
    }
  }
}
