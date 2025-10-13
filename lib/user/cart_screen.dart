import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../user/buyer_info_screen.dart'; // ✅ đúng đường dẫn

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await Provider.of<CartProvider>(
        context,
        listen: false,
      ).fetchCart(user.uid);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final items = cartProvider.cartItems;

    double total = items.fold(
      0,
      (sum, item) => sum + (item.car.price * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Giỏ hàng"), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text("🛒 Giỏ hàng trống"))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, index) {
                      final item = items[index];
                      return ListTile(
                        leading: Image.network(
                          item.car.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        title: Text(item.car.name),
                        subtitle: Text(
                          "${item.car.price.toStringAsFixed(0)} VND x${item.quantity}",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            cartProvider.removeFromCart(item.id);
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Tổng: ${total.toStringAsFixed(0)} VND",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) return;

                          // 👉 Mở form nhập thông tin người mua
                          final buyerInfo = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const BuyerInfoScreen(), // ✅ CHỮ HOA ĐÚNG
                            ),
                          );

                          // Nếu người dùng bấm Back thì không làm gì
                          if (buyerInfo == null) return;

                          final cars = items.map((e) => e.car).toList();

                          // ✅ Gửi thông tin đặt hàng kèm thông tin người mua
                          await Provider.of<OrderProvider>(
                            context,
                            listen: false,
                          ).placeOrder(
                            userId: user.uid,
                            cars: cars,
                            totalAmount: total,
                            buyerInfo:
                                buyerInfo, // ✅ TRUYỀN THÔNG TIN NGƯỜI MUA
                          );

                          for (var item in items) {
                            await Provider.of<CartProvider>(
                              context,
                              listen: false,
                            ).removeFromCart(item.id);
                          }

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("✅ Đặt hàng thành công"),
                            ),
                          );

                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text("Đặt hàng"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
