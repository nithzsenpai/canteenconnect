import 'package:flutter/foundation.dart';
import 'package:cafeteria_app/models/food_item_model.dart'; // You'll need your FoodItem model
import 'package:cafeteria_app/models/cart_item_model.dart'; // And your CartItem model

class CartProvider with ChangeNotifier {
  // Use the FoodItem's ID as the key for the map
  final Map<String, CartItem> _items = {};

  // Getter to access the cart items (returns a copy to prevent direct modification)
  Map<String, CartItem> get items {
    return {..._items};
  }

  // Getter for the number of unique items in the cart
  int get itemCount {
    return _items.length;
  }

  // Getter for the total quantity of all items in the cart
  int get totalQuantity {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  // Getter for the total amount (price) of all items in the cart
  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      // Each CartItem should have a FoodItem and a quantity
      // The price is on the FoodItem
      total += cartItem.foodItem.price * cartItem.quantity;
    });
    return total;
  }

  // Method to add an item to the cart
  void addItem(FoodItem foodItem) {
    if (_items.containsKey(foodItem.id)) {
      // If item already exists, increase its quantity
      _items.update(
        foodItem.id,
        (existingCartItem) => CartItem(
          foodItem: existingCartItem.foodItem, // or foodItem
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      // If item is new, add it to the cart with quantity 1
      _items.putIfAbsent(
        foodItem.id,
        () => CartItem(
          foodItem: foodItem,
          quantity: 1,
        ),
      );
    }
    notifyListeners(); // Notify listeners (UI) that the cart has changed
  }

  // Method to remove one unit of an item from the cart
  // If quantity becomes 0, the item is removed completely
  void removeItem(String foodItemId) {
    if (!_items.containsKey(foodItemId)) {
      return; // Item not in cart
    }
    if (_items[foodItemId]!.quantity > 1) {
      // If quantity is more than 1, decrease it
      _items.update(
        foodItemId,
        (existingCartItem) => CartItem(
          foodItem: existingCartItem.foodItem,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      // If quantity is 1, remove the item from the cart
      _items.remove(foodItemId);
    }
    notifyListeners();
  }

  // Method to remove an item completely from the cart, regardless of quantity
  void removeSingleItemCompletely(String foodItemId) {
    _items.remove(foodItemId);
    notifyListeners();
  }

  // Method to clear all items from the cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Helper method to get the current quantity of a specific item in the cart
  int getQuantity(String foodItemId) {
    return _items.containsKey(foodItemId) ? _items[foodItemId]!.quantity : 0;
  }
}