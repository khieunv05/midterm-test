import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';
import '../repositories/customer_repository.dart'; // File repo bạn đã tạo ở phần trước

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers quản lý text input
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalController = TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Tạo ID ngẫu nhiên hoặc dùng Email làm ID (ở đây dùng timestamp cho đơn giản)
      String newCustomerId = "CUS_${DateTime.now().millisecondsSinceEpoch}";

      final newCustomer = CustomerModel(
        customerId: newCustomerId,
        email: _emailController.text.trim(),
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        postalCode: _postalController.text.trim(),
        createdAt: DateTime.now(),
        isActive: true,
      );

      // Gọi Repository để lưu vào Firestore
      // Lưu ý: Bạn cần đảm bảo đã tạo file customer_repository.dart như hướng dẫn phần logic
      await CustomerRepository().addCustomer(newCustomer);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng ký thành công! Vui lòng đăng nhập.")),
        );
        Navigator.pop(context); // Quay về màn hình Login
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Hàm helper để tạo TextField cho gọn code
  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "Vui lòng nhập $label";
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đăng ký tài khoản")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_emailController, "Email", Icons.email, type: TextInputType.emailAddress),
              _buildTextField(_nameController, "Họ và Tên", Icons.person),
              _buildTextField(_phoneController, "Số điện thoại", Icons.phone, type: TextInputType.phone),
              _buildTextField(_addressController, "Địa chỉ", Icons.home),
              Row(
                children: [
                  Expanded(child: _buildTextField(_cityController, "Thành phố", Icons.location_city)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextField(_postalController, "Mã bưu điện", Icons.local_post_office, type: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("ĐĂNG KÝ NGAY", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}