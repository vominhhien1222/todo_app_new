import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/car_provider.dart';
//import '../../models/car.dart';
import 'add_car_screen.dart'; // 👈 Bước tiếp theo tạo màn thêm xe

class AdminCarsScreen extends StatefulWidget {
  const AdminCarsScreen({super.key});

  @override
  State<AdminCarsScreen> createState() => _AdminCarsScreenState();
}

class _AdminCarsScreenState extends State<AdminCarsScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    final provider = Provider.of<CarProvider>(context, listen: false);
    await provider.fetchCars();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final carProvider = Provider.of<CarProvider>(context);
    final cars = carProvider.cars;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý xe"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddCarScreen()),
              ).then((_) => _loadCars()); // refresh sau khi thêm
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : cars.isEmpty
          ? const Center(child: Text("Chưa có xe nào"))
          : ListView.builder(
              itemCount: cars.length,
              itemBuilder: (_, index) {
                final car = cars[index];
                return ListTile(
                  leading: Image.network(
                    car.imageUrl,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image),
                  ),
                  title: Text(car.name),
                  subtitle: Text(
                    "${car.brand} • ${car.price.toStringAsFixed(0)} VND",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      await carProvider.deleteCar(car.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("🗑️ Đã xóa xe")),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
