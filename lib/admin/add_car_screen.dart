import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/car.dart';
import '../../providers/car_provider.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  File? _imageFile;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<String> _uploadImage(File file) async {
    final fileName = 'cars/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child(fileName);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Vui lòng nhập đầy đủ thông tin và chọn ảnh"),
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final imageUrl = await _uploadImage(_imageFile!);

      final car = Car(
        id: '',
        name: _nameController.text.trim(),
        brand: _brandController.text.trim(),
        price: double.tryParse(_priceController.text) ?? 0,
        description: _descController.text.trim(),
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await Provider.of<CarProvider>(context, listen: false).addCar(car);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("✅ Thêm xe thành công")));
      Navigator.pop(context); // Quay lại màn danh sách xe
    } catch (e) {
      print("❌ Lỗi khi thêm xe: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Thêm xe thất bại")));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm xe mới")),
      body: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: _imageFile == null
                            ? const Center(child: Text("Chọn ảnh xe"))
                            : Image.file(_imageFile!, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Tên xe"),
                      validator: (val) =>
                          val == null || val.isEmpty ? "Nhập tên xe" : null,
                    ),
                    TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(labelText: "Hãng xe"),
                      validator: (val) =>
                          val == null || val.isEmpty ? "Nhập hãng xe" : null,
                    ),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: "Giá (VND)"),
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val == null || val.isEmpty ? "Nhập giá xe" : null,
                    ),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(labelText: "Mô tả xe"),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save),
                      label: const Text("Thêm xe"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
