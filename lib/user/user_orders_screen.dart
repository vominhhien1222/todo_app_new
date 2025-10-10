import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart' as my;

class UserOrdersScreen extends StatefulWidget {
  const UserOrdersScreen({super.key});

  @override
  State<UserOrdersScreen> createState() => _UserOrdersScreenState();
}

class _UserOrdersScreenState extends State<UserOrdersScreen> {
  bool _isLoading = true;
  List<my.Order> _userOrders = [];

  @override
  void initState() {
    super.initState();
    _loadUserOrders();
  }

  Future<void> _loadUserOrders() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final orders = await Provider.of<OrderProvider>(
        context,
        listen: false,
      ).fetchOrdersByUser(user.uid);

      setState(() {
        _userOrders = orders;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử đặt hàng"), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userOrders.isEmpty
          ? const Center(child: Text("Bạn chưa có đơn hàng nào."))
          : ListView.builder(
              itemCount: _userOrders.length,
              itemBuilder: (_, index) {
                final order = _userOrders[index];

                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ExpansionTile(
                    title: Text(
                      "Đơn hàng ngày ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}",
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Trạng thái: ${order.status}"),
                        Text(
                          "Tổng: ${order.totalAmount.toStringAsFixed(0)} VND",
                        ),
                      ],
                    ),
                    children: [
                      ...order.cars.map(
                        (car) => ListTile(
                          leading: Image.network(
                            car.imageUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(car.name),
                          subtitle: Text(
                            "${car.brand} • ${car.price.toStringAsFixed(0)} VND",
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
