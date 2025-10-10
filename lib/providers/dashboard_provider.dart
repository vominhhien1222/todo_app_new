import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  int totalOrders = 0;
  double totalRevenue = 0;
  Map<String, int> statusCount = {
    'pending': 0,
    'shipped': 0,
    'delivered': 0,
    'cancelled': 0,
  };

  /// 🔄 Lấy dữ liệu thống kê từ đơn hàng
  Future<void> fetchDashboardStats() async {
    try {
      final snapshot = await _firestore.collection('orders').get();

      totalOrders = snapshot.docs.length;
      totalRevenue = 0;
      statusCount.updateAll((key, value) => 0);

      for (final doc in snapshot.docs) {
        final data = doc.data();
        totalRevenue += (data['totalAmount'] ?? 0).toDouble();

        final status = data['status'] ?? 'pending';
        if (statusCount.containsKey(status)) {
          statusCount[status] = statusCount[status]! + 1;
        }
      }

      notifyListeners();
    } catch (e) {
      print("❌ Lỗi fetchDashboardStats: $e");
    }
  }
}
