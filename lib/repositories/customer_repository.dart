import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final CollectionReference _customerRef =
  FirebaseFirestore.instance.collection('customers');

  // 1. Thêm Customer
  Future<void> addCustomer(CustomerModel customer) async {
    await _customerRef.doc(customer.customerId).set(customer.toMap());
  }

  // 2. Lấy Customer theo ID
  Future<CustomerModel?> getCustomerById(String id) async {
    DocumentSnapshot doc = await _customerRef.doc(id).get();
    if (doc.exists) {
      return CustomerModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

// Các hàm Update, Delete, GetAll tương tự...
}