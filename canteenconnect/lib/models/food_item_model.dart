import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItem {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;

  var isFeatured;

  FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
  });

  factory FoodItem.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) { // Explicitly type DocumentSnapshot
    final data = doc.data(); // data is Map<String, dynamic>?
    if (data == null) {
      throw StateError('Missing data for FoodItem ID: ${doc.id}');
    }
    return FoodItem(
      id: doc.id,
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] as String? ?? '',
    );
  }

  // Renamed to toMap for consistency
  Map<String, dynamic> toMap() {
    return {
      // 'id' is usually not stored in the map if it's the document ID.
      // If you store it explicitly, then add it here.
      'name': name,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
    };
  }
}