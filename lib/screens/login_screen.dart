import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_2351060455/screens/signup_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/seed_data_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _login() async {
    // 1. Validate Form
    if (!_formKey.currentState!.validate()) return;

    // Bật trạng thái loading
    setState(() => _isLoading = true);

    try {
      String inputEmail = _emailController.text.trim();

      // 2. QUERY FIRESTORE: Tìm trong collection 'customers' xem có email này không
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('email', isEqualTo: inputEmail)
          .limit(1) // Chỉ lấy 1 kết quả đầu tiên tìm thấy
          .get();

      // 3. KIỂM TRA KẾT QUẢ
      if (snapshot.docs.isEmpty) {
        // => Không tìm thấy email này trong hệ thống
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Email chưa đăng ký hoặc không tồn tại!"),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false); // Tắt loading
        }
        return;
      }

      // 4. NẾU TÌM THẤY => Lấy thông tin thật
      var userDoc = snapshot.docs.first;
      String realCustomerId = userDoc.id;// Lấy ID thật từ field dữ liệu
      // Hoặc nếu bạn dùng DocID làm ID thì dùng: String realCustomerId = userDoc.id;
      String realName = userDoc['fullName'];

      // 5. LƯU VÀO SHARED PREFERENCES
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', inputEmail);
      await prefs.setString('customerId', realCustomerId); // Lưu ID thật
      await prefs.setString('fullName', realName); // Lưu tên để hiển thị (nếu cần)

      // 6. CHUYỂN MÀN HÌNH
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }

    } catch (e) {
      // Xử lý lỗi (ví dụ mất mạng)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi đăng nhập: $e")),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_bag, size: 80, color: Colors.blue),
                const SizedBox(height: 20),
                const Text("SHOPPING APP", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? "Vui lòng nhập email" : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading ? const CircularProgressIndicator() : const Text("Đăng Nhập"),
                  ),
                ),
                // ... Bên trong Column của LoginScreen
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Chưa có tài khoản?"),
                    TextButton(
                      onPressed: () {
                        // Chuyển sang màn hình đăng ký
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupScreen()),
                        );
                      },
                      child: const Text("Đăng ký ngay"),
                    ),
                  ],
                ),
                // ElevatedButton(
                //   onPressed: () async {
                //     // 1. Hiện loading
                //     ScaffoldMessenger.of(context).showSnackBar(
                //         const SnackBar(content: Text("Đang xóa dữ liệu cũ và tạo mới..."))
                //     );
                //
                //     // 2. Gọi hàm Xóa trước
                //     await SeedDataService().deleteAllData();
                //
                //     // 3. Gọi hàm Tạo mới sau
                //     await SeedDataService().seedData();
                //
                //     // 4. Thông báo xong
                //     ScaffoldMessenger.of(context).showSnackBar(
                //         const SnackBar(content: Text("✅ Đã làm mới dữ liệu thành công!"))
                //     );
                //   },
                //   style: ElevatedButton.styleFrom(backgroundColor: Colors.red), // Màu đỏ cảnh báo
                //   child: const Text("🔄 RESET DỮ LIỆU (XÓA CŨ & TẠO MỚI)"),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}