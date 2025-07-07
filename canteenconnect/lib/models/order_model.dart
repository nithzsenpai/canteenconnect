import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cafeteria_app/models/cart_item_model.dart';

class Order {
  final String? id; // Nullable for new orders before they get an ID from Firestore
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final String deliveryAddress;
  final String estimatedDeliveryTime; // e.g., "30-45 minutes"
  final String status; // e.g., "placed", "preparing", "out for delivery", "delivered"

  Order({
    this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.deliveryAddress,
    required this.estimatedDeliveryTime,
    this.status = 'placed',
  });

  // Renamed to toMap to be consistent with common Dart/Firestore practice
  // This matches what your FirestoreService.addOrder expects
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'orderDate': Timestamp.fromDate(orderDate),
      'deliveryAddress': deliveryAddress,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'status': status,
    };
  }

  factory Order.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) { // Explicitly type DocumentSnapshot
    final data = doc.data(); // data is already Map<String, dynamic>?
    if (data == null) {
      // Or handle more gracefully, e.g., return a default/error Order or throw
      throw StateError('Missing data for Order ID: ${doc.id}');
    }

    return Order(
      id: doc.id,
      userId: data['userId'] as String? ?? '', // Safe casting with fallback
     // Lines 41-43
items: (data['items'] as List<dynamic>? ?? [])
    .map<CartItem>((itemData) {
      final map = itemData as Map<String, dynamic>;
      final foodItemId = map['foodItemId'] as String? ?? '';
      return CartItem.fromMap(map, foodItemId);
    }).toList(),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0, // Safer number parsing
      orderDate: (data['orderDate'] as Timestamp? ?? Timestamp.now()).toDate(),
      deliveryAddress: data['deliveryAddress'] as String? ?? 'N/A',
      estimatedDeliveryTime: data['estimatedDeliveryTime'] as String? ?? 'N/A',
      status: data['status'] as String? ?? 'unknown',
    );
  }
}