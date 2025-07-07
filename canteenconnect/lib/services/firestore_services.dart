
// lib/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cafeteria_app/models/food_item_model.dart'; // Ensure this path is correct
import 'package:cafeteria_app/models/order_model.dart' as app_order; // Ensure this path and alias are correct

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Menu Items ---
  Stream<List<FoodItem>> getMenuItems() {
    return _db.collection('menu_items').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => FoodItem.fromFirestore(doc as DocumentSnapshot<Map<String,dynamic>>)).toList());
  }

  Stream<List<FoodItem>> getMenuItemsByCategory(String category) {
    return _db
        .collection('menu_items')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FoodItem.fromFirestore(doc as DocumentSnapshot<Map<String,dynamic>>))
            .toList());
  }

  Future<List<String>> getCategories() async {
    QuerySnapshot snapshot = await _db.collection('menu_items').get();
    Set<String> categories = {};
    for (var doc in snapshot.docs) {
      final categoryData = doc.data() as Map<String, dynamic>?;
      if (categoryData != null && categoryData['category'] is String) {
        categories.add(categoryData['category'] as String);
      }
    }
    return categories.toList();
  }

  // --- Orders ---
  Future<void> addOrder(app_order.Order order) {
    return _db.collection('orders').add(order.toMap()); // Assumes Order model has toMap()
  }

  Stream<List<app_order.Order>> getOrderHistory(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
          final List<app_order.Order> orders = snapshot.docs
              .map((doc) => app_order.Order.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>)) // Assumes Order model has fromFirestore()
              .toList();
          return orders;
        });
  }

  // --- Help Queries ---
  Future<void> submitHelpQuery({ // Using named parameters for clarity
    required String userId,
    required String name,
    required String email,
    required String question,
  }) {
    // Ensure your 'help_queries' collection exists or will be created.
    // You might want to add a try-catch block here for error handling.
    return _db.collection('help_queries').add({
      'userId': userId,       // ID of the user submitting the query
      'name': name,           // Name of the user
      'email': email,         // Email of the user
      'question': question,   // The actual question or issue
      'timestamp': FieldValue.serverTimestamp(), // Firestore server-side timestamp
      'status': 'submitted',  // Initial status (e.g., submitted, in progress, resolved)
    });
  }

  // --- User Profile ---
  // Fetches user profile data from a 'users' collection using the UID.
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data(); // Returns the user's data as a map
      }
      print("User profile not found for UID: $uid");
      return null; // User document doesn't exist or has no data
    } catch (e) {
      print("Error fetching user profile for UID $uid: $e");
      // Optionally, rethrow the error or return a specific error indicator
      return null;
    }
  }

  // Updates user profile data in the 'users' collection.
  // 'data' should be a Map<String, dynamic> of fields to update.
  Future<void> updateUserProfile(String uid, Map<String, dynamic> dataToUpdate) async {
    try {
      // You might want to add a server timestamp for 'lastUpdated' or similar
      // Map<String, dynamic> updatePayload = {
      //   ...dataToUpdate,
      //   'lastUpdatedAt': FieldValue.serverTimestamp(),
      // };
      // await _db.collection('users').doc(uid).update(updatePayload);
      await _db.collection('users').doc(uid).update(dataToUpdate);
      print("User profile updated successfully for UID: $uid");
    } catch (e) {
      print("Error updating user profile for UID $uid: $e");
      // Rethrow the error so the UI can handle it, e.g., show a SnackBar
      rethrow;
    }
  }
}
