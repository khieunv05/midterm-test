import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String productId;
  final String name;
  final String description;
  final double price;
  final String category;
  final String brand;
  final int stock;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final DateTime createdAt;

  ProductModel({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.brand,
    required this.stock,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'brand': brand,
      'stock': stock,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      productId: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      brand: map['brand'] ?? '',
      stock: map['stock'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isAvailable: map['isAvailable'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}