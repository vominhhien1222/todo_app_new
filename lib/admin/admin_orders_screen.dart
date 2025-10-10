import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart' as my;

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    await Provider.of<OrderProvider>(context, listen: false).fetchAllOrders();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders;

    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý đơn hàng"), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
          ? const Center(child: Text("Không có đơn hàng nào"))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (_, index) {
                final my.Order order = orders[index];

                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ExpansionTile(
                    title: Text("Mã đơn: ${order.id.substring(0, 6)}..."),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Người dùng: ${order.userId}"),
                        Text(
                          "Tổng tiền: ${order.totalAmount.toStringAsFixed(0)} VND",
                        ),
                        Text("Trạng thái: ${order.status}"),
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
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.broken_image),
                          ),
                          title: Text(car.name),
                          subtitle: Text(
                            "${car.brand} • ${car.price.toStringAsFixed(0)} VND",
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DropdownButton<String>(
                              value: order.status,
                              items: const [
                                DropdownMenuItem(
                                  value: 'pending',
                                  child: Text("Chờ duyệt"),
                                ),
                                DropdownMenuItem(
                                  value: 'approved',
                                  child: Text("Đã duyệt"),
                                ),
                                DropdownMenuItem(
                                  value: 'shipped',
                                  child: Text("Đã giao"),
                                ),
                              ],
                              onChanged: (value) async {
                                if (value == null) return;

                                await Provider.of<OrderProvider>(
                                  context,
                                  listen: false,
                                ).updateStatus(order.id, value);
                                _loadOrders();
                              },
                            ),
                            Text(
                              "${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
