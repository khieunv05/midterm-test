import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Thêm intl vào pubspec.yaml để format ngày
import '../models/order_model.dart';
import '../repositories/order_repository.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String? _customerId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _customerId = prefs.getString('customerId');
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_customerId == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text("Đơn hàng của tôi")),
      body: StreamBuilder<List<OrderModel>>(
        stream: OrderRepository().getOrdersByCustomer(_customerId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("Chưa có đơn hàng nào"));

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (ctx, i) {
              final order = orders[i];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text("Đơn #${order.orderId.substring(0, 5)}..."),
                  subtitle: Text("${DateFormat('dd/MM/yyyy HH:mm').format(order.orderDate)} - \$${order.total}"),
                  trailing: Chip(
                    label: Text(order.status.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10)),
                    backgroundColor: _getStatusColor(order.status),
                  ),
                  children: [
                    ...order.items.map((item) => ListTile(
                      title: Text(item['productName']),
                      trailing: Text("x${item['quantity']} = \$${item['price'] * item['quantity']}"),
                    )),
                    if (order.status == 'pending')
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                          onPressed: () async {
                            await OrderRepository().updateOrderStatus(order.orderId, 'cancelled');
                          },
                          child: const Text("Hủy đơn hàng"),
                        ),
                      )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}