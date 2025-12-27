import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductRepository {
  final CollectionReference _productRef =
  FirebaseFirestore.instance.collection('products');

  // 3. Lấy tất cả Products (Realtime Stream cho UI)
  Stream<List<ProductModel>> getProductsStream() {
    return _productRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  // 4. Tìm kiếm (Firestore hạn chế tìm kiếm like %%, đây là giải pháp cơ bản)
  Future<List<ProductModel>> searchProducts(String query) async {
    // Lưu ý: Firestore chỉ hỗ trợ prefix search tốt
    QuerySnapshot snapshot = await _productRef
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: query + 'z')
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  // 5. Lọc theo Category
  Future<List<ProductModel>> getProductsByCategory(String category) async {
    QuerySnapshot snapshot = await _productRef.where('category', isEqualTo: category).get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}