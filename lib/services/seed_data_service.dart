import 'package:cloud_firestore/cloud_firestore.dart';

class SeedDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedData() async {
    final batch = _firestore.batch();

    // ---------------------------------------------------------
    // 1. TẠO 5 CUSTOMERS (Mã: CUS_001 -> CUS_005)
    // ---------------------------------------------------------
    var customers = [
      {'id': 'CUS_001', 'name': 'Nguyen Van A', 'email': 'a@test.com', 'city': 'Ho Chi Minh'},
      {'id': 'CUS_002', 'name': 'Tran Thi B', 'email': 'b@test.com', 'city': 'Ha Noi'},
      {'id': 'CUS_003', 'name': 'Le Van C', 'email': 'c@test.com', 'city': 'Da Nang'},
      {'id': 'CUS_004', 'name': 'Pham Thi D', 'email': 'd@test.com', 'city': 'Can Tho'},
      {'id': 'CUS_005', 'name': 'Hoang Van E', 'email': 'e@test.com', 'city': 'Hai Phong'},
    ];

    for (var c in customers) {
      var docRef = _firestore.collection('customers').doc(c['id']);
      batch.set(docRef, {
        'customerId': c['id'],
        'email': c['email'],
        'fullName': c['name'],
        'phoneNumber': '0901234567',
        'address': '123 Đường ABC',
        'city': c['city'],
        'postalCode': '700000',
        'createdAt': Timestamp.now(),
        'isActive': true,
      });
    }

    // ---------------------------------------------------------
    // 2. TẠO 15 PRODUCTS (Mã: PROD_001 -> PROD_015)
    // ---------------------------------------------------------
    // Thay thế đoạn products cũ bằng đoạn này:
    var products = [
      // Electronics (Dùng ảnh công nghệ ngẫu nhiên)
      {'id': 'PROD_001', 'name': 'iPhone 15 Pro', 'price': 999.0, 'cat': 'Electronics', 'img': 'https://loremflickr.com/320/240/smartphone'},
      {'id': 'PROD_002', 'name': 'MacBook Air M2', 'price': 1199.0, 'cat': 'Electronics', 'img': 'https://loremflickr.com/320/240/laptop'},
      {'id': 'PROD_003', 'name': 'Sony Headphones', 'price': 299.0, 'cat': 'Electronics', 'img': 'https://loremflickr.com/320/240/headphones'},
      {'id': 'PROD_004', 'name': 'Samsung Galaxy S24', 'price': 899.0, 'cat': 'Electronics', 'img': 'https://loremflickr.com/320/240/mobile'},

      // Clothing (Dùng ảnh thời trang)
      {'id': 'PROD_005', 'name': 'Ao Thun Basic', 'price': 15.0, 'cat': 'Clothing', 'img': 'https://loremflickr.com/320/240/shirt'},
      {'id': 'PROD_006', 'name': 'Quan Jean Nam', 'price': 45.0, 'cat': 'Clothing', 'img': 'https://loremflickr.com/320/240/jeans'},
      {'id': 'PROD_007', 'name': 'Vay Hoa Nu', 'price': 35.0, 'cat': 'Clothing', 'img': 'https://loremflickr.com/320/240/dress'},
      {'id': 'PROD_008', 'name': 'Ao Khoac Hoodie', 'price': 55.0, 'cat': 'Clothing', 'img': 'https://loremflickr.com/320/240/clothing'},

      // Food (Dùng ảnh đồ ăn)
      {'id': 'PROD_009', 'name': 'Pizza Hai San', 'price': 20.0, 'cat': 'Food', 'img': 'https://loremflickr.com/320/240/pizza'},
      {'id': 'PROD_010', 'name': 'Burger Bo', 'price': 10.0, 'cat': 'Food', 'img': 'https://loremflickr.com/320/240/burger'},
      {'id': 'PROD_011', 'name': 'Tra Sua Tran Chau', 'price': 5.0, 'cat': 'Food', 'img': 'https://loremflickr.com/320/240/drink'},

      // Books (Dùng ảnh sách)
      {'id': 'PROD_012', 'name': 'Flutter For Dummies', 'price': 25.0, 'cat': 'Books', 'img': 'https://loremflickr.com/320/240/book'},
      {'id': 'PROD_013', 'name': 'Clean Code', 'price': 40.0, 'cat': 'Books', 'img': 'https://loremflickr.com/320/240/coding'},
      {'id': 'PROD_014', 'name': 'Dac Nhan Tam', 'price': 12.0, 'cat': 'Books', 'img': 'https://loremflickr.com/320/240/novel'},

      // Toys (Dùng ảnh đồ chơi)
      {'id': 'PROD_015', 'name': 'Lego City', 'price': 60.0, 'cat': 'Toys', 'img': 'https://loremflickr.com/320/240/lego'},
    ];

    for (var p in products) {
      var docRef = _firestore.collection('products').doc(p['id'].toString());
      batch.set(docRef, {
        'productId': p['id'],
        'name': p['name'],
        'description': 'Mô tả chi tiết cho sản phẩm ${p['name']}. Chất lượng tốt, giá cả phải chăng.',
        'price': p['price'],
        'category': p['cat'],
        'brand': 'No Brand',
        'stock': 100, // Stock mặc định
        'imageUrl': p['img'],
        'rating': 4.5,
        'reviewCount': 10,
        'isAvailable': true,
        'createdAt': Timestamp.now(),
      });
    }

    // ---------------------------------------------------------
    // 3. TẠO 8 ORDERS (Có nhiều trạng thái)
    // ---------------------------------------------------------
    var orders = [
      {'id': 'ORD_001', 'cusId': 'CUS_001', 'status': 'pending', 'total': 1029.0},
      {'id': 'ORD_002', 'cusId': 'CUS_001', 'status': 'delivered', 'total': 50.0},
      {'id': 'ORD_003', 'cusId': 'CUS_002', 'status': 'processing', 'total': 1200.0},
      {'id': 'ORD_004', 'cusId': 'CUS_002', 'status': 'cancelled', 'total': 30.0},
      {'id': 'ORD_005', 'cusId': 'CUS_003', 'status': 'shipped', 'total': 900.0},
      {'id': 'ORD_006', 'cusId': 'CUS_004', 'status': 'pending', 'total': 45.0},
      {'id': 'ORD_007', 'cusId': 'CUS_005', 'status': 'confirmed', 'total': 60.0},
      {'id': 'ORD_008', 'cusId': 'CUS_005', 'status': 'delivered', 'total': 25.0},
    ];

    for (var o in orders) {
      var docRef = _firestore.collection('orders').doc(o['id'].toString());
      batch.set(docRef, {
        'orderId': o['id'],
        'customerId': o['cusId'],
        'items': [
          // Fake items data cho có lệ
          {'productId': 'PROD_001', 'productName': 'Sample Product', 'quantity': 1, 'price': o['total']}
        ],
        'subtotal': o['total'],
        'shippingFee': 30.0,
        'total': (o['total'] as double) + 30.0,
        'orderDate': Timestamp.now(),
        'shippingAddress': '123 Test Street',
        'status': o['status'],
        'paymentMethod': 'cash',
        'paymentStatus': 'pending',
        'notes': 'Giao hàng giờ hành chính',
      });
    }

    // Commit tất cả dữ liệu
    await batch.commit();
    print("✅ ĐÃ TẠO DỮ LIỆU MẪU THÀNH CÔNG!");
  }
  Future<void> deleteAllData() async {
    // Danh sách các collection cần xóa
    List<String> collections = ['products', 'customers', 'orders'];

    for (var collectionName in collections) {
      var snapshot = await _firestore.collection(collectionName).get();
      // Dùng Batch để xóa cho nhanh và an toàn
      WriteBatch batch = _firestore.batch();

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print("Deleted all docs in $collectionName");
    }
    print("✅ ĐÃ XÓA SẠCH DỮ LIỆU CŨ!");
  }
}
