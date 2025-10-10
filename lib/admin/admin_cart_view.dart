import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminCartViewScreen extends StatelessWidget {
  const AdminCartViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Giỏ hàng người dùng"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('carts').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Không có giỏ hàng nào"));
          }

          // Gom các cart item theo userId
          final grouped = <String, List<QueryDocumentSnapshot>>{};
          for (var doc in snapshot.data!.docs) {
            final userId = doc['userId'];
            grouped.putIfAbsent(userId, () => []).add(doc);
          }

          final userIds = grouped.keys.toList();

          return ListView.builder(
            itemCount: userIds.length,
            itemBuilder: (_, index) {
              final userId = userIds[index];
              final userCart = grouped[userId]!;

              return ExpansionTile(
                title: Text("User ID: $userId"),
                subtitle: Text("Số lượng: ${userCart.length} xe"),
                children: userCart.map((doc) {
                  final car = doc['car'];
                  return ListTile(
                    leading: Image.network(
                      car['imageUrl'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported),
                    ),
                    title: Text(car['name']),
                    subtitle: Text("${car['brand']} • ${car['price']} VND"),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
