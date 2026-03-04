import 'dart:convert';
import 'package:flutter/services.dart';

// ============================================================
// MODEL
// ============================================================

class BlinkitProduct {
  final String id;
  final String name;
  final String brand;
  final String imageUrl;
  final String quantity;
  final double price;
  final double? mrp;
  final double rating;
  final int ratingCount;
  final int deliveryMins;
  final int? discountPercent;
  final bool isLowStock;

  const BlinkitProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.quantity,
    required this.price,
    this.mrp,
    required this.rating,
    required this.ratingCount,
    required this.deliveryMins,
    this.discountPercent,
    this.isLowStock = false,
  });

  factory BlinkitProduct.fromJson(Map<String, dynamic> json) {
    return BlinkitProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      imageUrl: json['imageUrl'] as String,
      quantity: json['quantity'] as String,
      price: (json['price'] as num).toDouble(),
      mrp: (json['mrp'] as num?)?.toDouble(),
      rating: (json['rating'] as num).toDouble(),
      ratingCount: json['ratingCount'] as int,
      deliveryMins: json['deliveryMins'] as int,
      discountPercent: json['discountPercent'] as int?,
      isLowStock: json['isLowStock'] as bool? ?? false,
    );
  }
}

// ============================================================
// REPOSITORY
// ============================================================

class BlinkitProductRepository {
  static const _assetPath = 'assets/data/blinkit_products.json';

  static Future<List<BlinkitProduct>> load() async {
    final jsonString = await rootBundle.loadString(_assetPath);
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((e) => BlinkitProduct.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
