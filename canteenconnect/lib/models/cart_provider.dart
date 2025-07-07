import 'package:cafeteria_app/models/cart_item_model.dart';
import 'package:cafeteria_app/models/food_item_model.dart';
import 'package:flutter/foundation.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {}; // Use FoodItem ID as key

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  int get totalQuantity {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.foodItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(FoodItem foodItem) {
    if (_items.containsKey(foodItem.id)) {
      _items.update(
        foodItem.id,
        (existingCartItem) => CartItem(
          foodItem: existingCartItem.foodItem,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        foodItem.id,
        () => CartItem(foodItem: foodItem, quantity: 1),
      );
    }
    notifyListeners();
  }

  void removeItem(String foodItemId) { // Remove one quantity of the item
    if (!_items.containsKey(foodItemId)) return;

    if (_items[foodItemId]!.quantity > 1) {
      _items.update(
        foodItemId,
        (existing) => CartItem(
          foodItem: existing.foodItem,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(foodItemId); // Remove item completely if quantity is 1
    }
    notifyListeners();
  }

  void removeSingleItemCompletely(String foodItemId) { // Remove all quantities of an item
    _items.remove(foodItemId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  int getQuantity(String foodItemId) {
    return _items.containsKey(foodItemId) ? _items[foodItemId]!.quantity : 0;
  }
}