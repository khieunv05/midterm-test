import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String orderId;
  final String customerId;
  final List<Map<String, dynamic>> items; // productId, productName, quantity, price
  final double subtotal;
  final double shippingFee;
  final double total;
  final DateTime orderDate;
  final String shippingAddress;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final String? notes;

  OrderModel({
    required this.orderId,
    required this.customerId,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.orderDate,
    required this.shippingAddress,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'items': items,
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'total': total,
      'orderDate': Timestamp.fromDate(orderDate),
      'shippingAddress': shippingAddress,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'notes': notes,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      orderId: id,
      customerId: map['customerId'] ?? '',
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      shippingFee: (map['shippingFee'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      orderDate: (map['orderDate'] as Timestamp).toDate(),
      shippingAddress: map['shippingAddress'] ?? '',
      status: map['status'] ?? 'pending',
      paymentMethod: map['paymentMethod'] ?? '',
      paymentStatus: map['paymentStatus'] ?? '',
      notes: map['notes'],
    );
  }
}