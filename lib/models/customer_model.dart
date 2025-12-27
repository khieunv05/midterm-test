import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String customerId;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String address;
  final String city;
  final String postalCode;
  final DateTime createdAt;
  final bool isActive;

  CustomerModel({
    required this.customerId,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.createdAt,
    required this.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map, String id) {
    return CustomerModel(
      customerId: id,
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      postalCode: map['postalCode'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
    );
  }
}