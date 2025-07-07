import 'package:cafeteria_app/models/food_item_model.dart';

class CartItem {
  final FoodItem foodItem;
  int quantity;

  CartItem({required this.foodItem, this.quantity = 1});

  double get totalPrice => foodItem.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'foodItemId': foodItem.id, // This is the ID of the FoodItem
      'name': foodItem.name,
      'price': foodItem.price,
      'quantity': quantity,
      'imageUrl': foodItem.imageUrl,
      // 'category': foodItem.category, // Consider adding category if needed for display in order details
    };
  }

  // 'mapFromOrder' is the map for ONE item from the order's 'items' array.
  // 'foodItemIdFromOrder' is the ID that was stored as 'foodItemId' in that map.
  factory CartItem.fromMap(Map<String, dynamic> mapFromOrder, String foodItemIdFromOrder) {
    return CartItem(
      foodItem: FoodItem(
        // Use the ID passed from the order, which was originally foodItem.id
        id: foodItemIdFromOrder,
        name: mapFromOrder['name'] as String? ?? 'Unknown Item',
        // Category is often not stored directly in the cart item's map in the order.
        // If you need it, you'd have to fetch the FoodItem from 'menu_items' collection
        // using foodItemIdFromOrder or ensure 'category' is also saved in CartItem.toMap().
        // For now, providing a default or assuming it's not critical for CartItem display.
        category: mapFromOrder['category'] as String? ?? 'Unknown Category', // If you decide to store it in toMap()
        price: (mapFromOrder['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: mapFromOrder['imageUrl'] as String? ?? '',
      ),
      quantity: (mapFromOrder['quantity'] as num?)?.toInt() ?? 1,
    );
  }
}