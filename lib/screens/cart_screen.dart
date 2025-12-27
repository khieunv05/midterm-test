import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/cart_provider.dart';
import '../models/order_model.dart';
import '../repositories/order_repository.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isOrdering = false;

  // Hiển thị BottomSheet để điền thông tin đặt hàng
  void _showCheckoutBottomSheet(BuildContext context, CartProvider cart) {
    // Controller cho địa chỉ
    final addressController = TextEditingController(text: "");
    // Biến lưu phương thức thanh toán đang chọn
    String selectedPayment = "cash";
    // Phí ship cố định (Theo đề bài hoặc logic của bạn)
    const double shippingFee = 30.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Để dialog full lên khi bàn phím hiện
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder( // Dùng StatefulBuilder để update lại UI trong BottomSheet (ví dụ khi chọn payment)
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                  top: 20, left: 20, right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text("XÁC NHẬN ĐƠN HÀNG",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(),

                  // 1. Nhập địa chỉ giao hàng
                  const Text("Địa chỉ giao hàng:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      hintText: "Nhập số nhà, tên đường, phường/xã...",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // 2. Chọn phương thức thanh toán
                  const Text("Phương thức thanh toán:", style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String>(
                    value: selectedPayment,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: "cash", child: Text("Tiền mặt (COD)")),
                      DropdownMenuItem(value: "card", child: Text("Thẻ tín dụng")),
                      DropdownMenuItem(value: "bank_transfer", child: Text("Chuyển khoản ngân hàng")),
                    ],
                    onChanged: (val) {
                      setModalState(() {
                        selectedPayment = val!;
                      });
                    },
                  ),
                  const SizedBox(height: 15),

                  // 3. Tính toán chi phí
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8)
                    ),
                    child: Column(
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text("Tạm tính:"),
                          Text("\$${cart.totalAmount.toStringAsFixed(2)}"),
                        ]),
                        const SizedBox(height: 5),
                        const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text("Phí vận chuyển:"),
                          Text("+\$30.0", style: TextStyle(color: Colors.red)), // Hardcode $30 ship
                        ]),
                        const Divider(),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          const Text("TỔNG CỘNG:", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("\$${(cart.totalAmount + shippingFee).toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Nút xác nhận đặt hàng
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                      onPressed: _isOrdering
                          ? null
                          : () async {
                        if (addressController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập địa chỉ!")));
                          return;
                        }
                        Navigator.pop(ctx); // Đóng BottomSheet
                        // Gọi hàm xử lý logic
                        await _processOrder(cart, addressController.text, selectedPayment, shippingFee);
                      },
                      child: const Text("HOÀN TẤT ĐẶT HÀNG"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Hàm xử lý logic gọi xuống Repository
  Future<void> _processOrder(CartProvider cart, String address, String paymentMethod, double shippingFee) async {
    setState(() => _isOrdering = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerId = prefs.getString('customerId') ?? 'unknown_user';

      // Tạo List Items
      List<Map<String, dynamic>> orderItems = [];
      cart.items.forEach((key, cartItem) {
        orderItems.add({
          'productId': cartItem.product.productId,
          'productName': cartItem.product.name,
          'quantity': cartItem.quantity,
          'price': cartItem.product.price,
        });
      });

      // Tạo Model
      final newOrder = OrderModel(
        orderId: '',
        customerId: customerId,
        items: orderItems,
        subtotal: cart.totalAmount,
        shippingFee: shippingFee,
        total: cart.totalAmount + shippingFee,
        orderDate: DateTime.now(),
        shippingAddress: address, // Lấy từ input
        status: "pending",
        paymentMethod: paymentMethod, // Lấy từ dropdown
        paymentStatus: "pending",
      );

      // Gọi Repository
      await OrderRepository().createOrder(newOrder);

      cart.clear(); // Xóa giỏ
      if (mounted) {
        // Thông báo thành công
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Thành công!"),
            content: const Text("Đơn hàng của bạn đã được ghi nhận."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: ${e.toString()}")));
      }
    } finally {
      if (mounted) setState(() => _isOrdering = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Giỏ hàng")),
      body: cart.items.isEmpty
          ? const Center(child: Text("Giỏ hàng đang trống", style: TextStyle(fontSize: 18, color: Colors.grey)))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) {
                var key = cart.items.keys.toList()[i];
                var item = cart.items[key]!;
                return ListTile(
                  leading: Image.network(item.product.imageUrl, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_,__,___)=> const Icon(Icons.image)),
                  title: Text(item.product.name),
                  subtitle: Text("x${item.quantity}  -  \$${(item.product.price * item.quantity).toStringAsFixed(0)}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.remove), onPressed: () => cart.removeSingleItem(key)),
                      IconButton(icon: const Icon(Icons.add), onPressed: () => cart.addItem(item.product)),
                    ],
                  ),
                );
              },
            ),
          ),
          // Phần tổng tiền và nút đặt hàng
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black12)]
            ),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text("Tổng cộng (Chưa ship):", style: TextStyle(fontSize: 16)),
                  Text("\$${cart.totalAmount.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    // 👇 Bấm nút này sẽ hiện BottomSheet
                    onPressed: (cart.items.isEmpty || _isOrdering)
                        ? null
                        : () => _showCheckoutBottomSheet(context, cart),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    child: _isOrdering
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("TIẾN HÀNH ĐẶT HÀNG"),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}