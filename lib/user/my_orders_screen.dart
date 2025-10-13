import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart' as my;

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  bool _isLoading = true;
  List<my.Order> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final fetchedOrders = await Provider.of<OrderProvider>(
      context,
      listen: false,
    ).fetchOrdersByUser(user.uid);

    setState(() {
      _orders = fetchedOrders;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đơn hàng của tôi"), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? const Center(child: Text("Bạn chưa có đơn hàng nào"))
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (_, index) {
                final order = _orders[index];

                return Card(
                  margin: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ExpansionTile(
                    title: Text(
                      "🧾 Mã đơn: ${order.id.substring(0, 6)}...",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tổng tiền: ${order.totalAmount.toStringAsFixed(0)} VND",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text("Trạng thái: ${order.status}"),
                        Text(
                          "Ngày đặt: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    children: [
                      if (order.buyerInfo != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "📦 Thông tin người mua",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Họ tên: ${order.buyerInfo?['name'] ?? '—'}",
                                ),
                                Text(
                                  "SĐT: ${order.buyerInfo?['phone'] ?? '—'}",
                                ),
                                Text(
                                  "Email: ${order.buyerInfo?['email'] ?? '—'}",
                                ),
                                Text(
                                  "Địa chỉ: ${order.buyerInfo?['address'] ?? '—'}",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ...order.cars.map(
                        (car) => ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              car.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image),
                            ),
                          ),
                          title: Text(car.name),
                          subtitle: Text(
                            "${car.brand} • ${car.price.toStringAsFixed(0)} VND",
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
