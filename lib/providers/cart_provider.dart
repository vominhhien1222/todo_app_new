import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car.dart';
import '../models/cart_item.dart';

class CartProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;

  /// 🔄 Lấy danh sách giỏ hàng của user
  Future<void> fetchCart(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('carts')
          .where('userId', isEqualTo: userId)
          .get();

      _cartItems = snapshot.docs
          .map((doc) => CartItem.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners();
    } catch (e) {
      print("❌ Lỗi fetchCart: $e");
    }
  }

  /// ➕ Thêm vào giỏ hàng
  Future<void> addToCart(Car car, String userId) async {
    try {
      await _firestore.collection('carts').add({
        'userId': userId,
        'car': car.toMap(),
        'carId': car.id,
        'quantity': 1,
        'createdAt': DateTime.now().toIso8601String(),
      });
      await fetchCart(userId); // 👈 Sau khi thêm, load lại giỏ
    } catch (e) {
      print("❌ Lỗi thêm vào giỏ: $e");
    }
  }

  /// ❌ Xoá khỏi giỏ hàng
  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _firestore.collection('carts').doc(cartItemId).delete();
      _cartItems.removeWhere((item) => item.id == cartItemId);
      notifyListeners();
    } catch (e) {
      print("❌ Lỗi xóa giỏ hàng: $e");
    }
  }
}
