import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart'; // Import Provider giỏ hàng

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Kiểm tra trạng thái còn hàng hay hết hàng
    bool isOutOfStock = product.stock <= 0;

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Column(
        children: [
          // 1. Phần hình ảnh (chiếm 40% màn hình)
          Expanded(
            flex: 4,
            child: SizedBox(
              width: double.infinity,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 100, color: Colors.grey)),
              ),
            ),
          ),

          // 2. Phần thông tin chi tiết
          Expanded(
            flex: 6,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên và Giá
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        "\$${product.price}",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Category, Brand, Rating
                  Row(
                    children: [
                      Chip(label: Text(product.category), backgroundColor: Colors.blue[50]),
                      const SizedBox(width: 10),
                      Icon(Icons.star, color: Colors.amber, size: 20),
                      Text(" ${product.rating} (${product.reviewCount} reviews)"),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Mô tả
                  const Text("Mô tả sản phẩm:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        product.description,
                        style: const TextStyle(color: Colors.grey, height: 1.5),
                      ),
                    ),
                  ),

                  const Divider(),

                  // Phần Stock và Nút bấm
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Tình trạng:", style: TextStyle(color: Colors.grey)),
                          Text(
                            isOutOfStock ? "Hết hàng" : "Còn lại: ${product.stock}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isOutOfStock ? Colors.red : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 20),

                      // Nút Thêm vào giỏ (Chỉ hiện nếu stock > 0)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isOutOfStock
                              ? null // Disable nút nếu hết hàng
                              : () {
                            // Gọi Provider thêm vào giỏ
                            Provider.of<CartProvider>(context, listen: false).addItem(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Đã thêm ${product.name} vào giỏ!"),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isOutOfStock ? Colors.grey : Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                          ),
                          icon: const Icon(Icons.shopping_cart_checkout),
                          label: Text(isOutOfStock ? "TẠM HẾT HÀNG" : "THÊM VÀO GIỎ"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}