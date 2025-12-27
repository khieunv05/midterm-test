import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Đặt Hàng (Create Order) - Transaction
  // 1. Đặt Hàng (Create Order) - Transaction CHUẨN (Fix lỗi nhiều item)
  Future<void> createOrder(OrderModel order) async {
    await _firestore.runTransaction((transaction) async {
      // --- GIAI ĐOẠN 1: ĐỌC VÀ KIỂM TRA (READ PHASE) ---
      List<DocumentSnapshot> productSnapshots = [];
      List<DocumentReference> productRefs = [];

      for (var item in order.items) {
        String productId = item['productId'];
        DocumentReference ref = _firestore.collection('products').doc(productId);

        // Đọc dữ liệu
        DocumentSnapshot snapshot = await transaction.get(ref);

        if (!snapshot.exists) {
          throw Exception("Sản phẩm ${item['productName']} không còn tồn tại!");
        }

        // Kiểm tra số lượng tồn kho ngay lúc đọc
        int quantity = item['quantity'];
        int currentStock = snapshot.get('stock'); // Đảm bảo field 'stock' trong DB là số (int)

        if (currentStock < quantity) {
          throw Exception("Sản phẩm '${item['productName']}' không đủ hàng (Chỉ còn $currentStock)!");
        }

        // Lưu lại để dùng cho giai đoạn ghi
        productSnapshots.add(snapshot);
        productRefs.add(ref);
      }

      // --- GIAI ĐOẠN 2: GHI VÀ CẬP NHẬT (WRITE PHASE) ---
      for (int i = 0; i < order.items.length; i++) {
        var item = order.items[i];
        int quantity = item['quantity'];
        int currentStock = productSnapshots[i].get('stock');

        // Thực hiện trừ kho
        transaction.update(productRefs[i], {'stock': currentStock - quantity});
      }

      // Cuối cùng mới tạo đơn hàng
      DocumentReference orderRef = _firestore.collection('orders').doc();
      transaction.set(orderRef, order.toMap());
    });
  }

  // 2. Cập nhật trạng thái & Hủy đơn (Trả lại stock)
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _firestore.runTransaction((transaction) async {
      DocumentReference orderRef = _firestore.collection('orders').doc(orderId);
      DocumentSnapshot orderSnap = await transaction.get(orderRef);

      if(!orderSnap.exists) throw Exception("Order not found");

      String currentStatus = orderSnap.get('status');

      // Nếu đang pending mà chuyển sang cancelled -> Trả lại stock
      if (currentStatus != 'cancelled' && newStatus == 'cancelled') {
        List<dynamic> items = orderSnap.get('items');
        for (var item in items) {
          String productId = item['productId'];
          int quantity = item['quantity'];

          DocumentReference productRef = _firestore.collection('products').doc(productId);
          // Dùng FieldValue.increment để tăng an toàn
          transaction.update(productRef, {'stock': FieldValue.increment(quantity)});
        }
      }

      transaction.update(orderRef, {'status': newStatus});
    });
  }

  // 3. Lấy đơn hàng của Customer
  Stream<List<OrderModel>> getOrdersByCustomer(String customerId) {
    return _firestore
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList());
  }
}