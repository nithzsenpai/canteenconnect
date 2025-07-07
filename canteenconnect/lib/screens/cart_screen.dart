// lib/screens/cart_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math'; // For random estimated time

// Crucial Imports - ensure these files exist at these paths
import 'package:cafeteria_app/models/order_model.dart' as app_order; // Assuming order_model.dart and prefix
// If your model is order_model1.dart, use:
// import 'package:cafeteria_app/models/order_model1.dart' as app_order;

import 'package:cafeteria_app/providers/auth_provider.dart' as MyAppAuthProvider;
import 'package:cafeteria_app/providers/cart_provider.dart'; // For CartProvider
import 'package:cafeteria_app/screens/checkout_screen.dart'; // For CheckoutScreen
import 'package:cafeteria_app/screens/home_screen.dart';
import 'package:cafeteria_app/screens/profile_screen.dart';
import 'package:cafeteria_app/services/firestore_service.dart';
import 'package:cafeteria_app/utils/app_colors.dart'; // For AppColors
import 'package:cafeteria_app/utils/app_text_styles.dart'; // For AppTextStyles
import 'package:cafeteria_app/widgets/bottom_nav_bar.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _deliveryAddressController = TextEditingController(text: " ");
  final FirestoreService _firestoreService = FirestoreService(); // Ensure FirestoreService() is constructible
  bool _isPlacingOrder = false; // To manage loading state for place order

  @override
  void dispose() {
    _deliveryAddressController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    if (_isPlacingOrder) return; // Prevent navigation while placing order

    if (index == 0) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (route) => false);
    } else if (index == 1) {
      // Already on cart screen
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
  }

  Future<void> _placeOrder(CartProvider cartProvider, String userId) async {
    if (_isPlacingOrder) return; // Prevent multiple submissions

    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Your cart is empty!")),
      );
      return;
    }
    if (_deliveryAddressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a delivery address.")),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true; // Show loading state
    });

    final randomMinutes = Random().nextInt(21) + 25; // 25 to 45 minutes
    final estimatedTime = "$randomMinutes-${randomMinutes + 15} mins";

    final order = app_order.Order( // Use the prefixed 'app_order.Order'
      userId: userId,
      items: cartProvider.items.values.toList(), // Ensure CartItem model is compatible
      totalAmount: cartProvider.totalAmount,
      orderDate: DateTime.now(),
      deliveryAddress: _deliveryAddressController.text.trim(),
      estimatedDeliveryTime: estimatedTime,
      status: 'Placed',
    );

    try {
      await _firestoreService.addOrder(order); // Ensure addOrder expects app_order.Order
      cartProvider.clearCart();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => CheckoutScreen(estimatedDeliveryTime: estimatedTime)),
              (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print("Error placing order: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to place order: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false; // Hide loading state
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // It's good practice to get providers inside the build method if they might change
    // or if you only need them for the build.
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<MyAppAuthProvider.AuthProvider>(context, listen: false);
    final String? userId = authProvider.user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart', style: TextStyle(color: AppColors.appWhite)),
        backgroundColor: AppColors.orangePrimary,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.orangeGradient)),
        iconTheme: const IconThemeData(color: AppColors.appWhite),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.orangeGradient),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery Address', style: AppTextStyles.stylishWhiteBold.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            TextField(
              controller: _deliveryAddressController,
              style: AppTextStyles.stylishBlackInput, // Ensure this style is defined
              decoration: InputDecoration(
                hintText: 'Enter your delivery address',
                hintStyle: AppTextStyles.stylishBlackInput.copyWith(color: AppColors.textBlack.withOpacity(0.6)), // Using textBlack
                filled: true,
                fillColor: AppColors.appWhite.withOpacity(0.9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.orangeDark),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.appWhite, size: 20),
                const SizedBox(width: 8),
                Text('Estimated Delivery:', style: AppTextStyles.stylishWhiteBold.copyWith(fontSize: 16)),
                const SizedBox(width: 5),
                Text('10-15 minutes', style: AppTextStyles.bodyTextWhite.copyWith(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 15),
            const Divider(color: AppColors.appWhite, thickness: 0.5),

            Text('Item Summary', style: AppTextStyles.stylishWhiteBold.copyWith(fontSize: 18)),
            const SizedBox(height: 10),
            Expanded(
              child: cartProvider.items.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.remove_shopping_cart_outlined, size: 60, color: AppColors.appWhite),
                    const SizedBox(height: 16),
                    Text('Your cart is empty!', style: AppTextStyles.stylishWhiteInput.copyWith(fontSize: 18)),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text(
                        'Looks like you haven\'t added anything yet. Go ahead and explore our menu!',
                        style: AppTextStyles.subtitleWhite,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: cartProvider.items.length,
                itemBuilder: (context, index) {
                  final cartItem = cartProvider.items.values.toList()[index];
                  return Card(
                    color: AppColors.appWhite.withOpacity(0.95),
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 2,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          cartItem.foodItem.imageUrl.isNotEmpty ? cartItem.foodItem.imageUrl : 'https://via.placeholder.com/60',
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, st) => Container(
                              width: 60, height: 60, color: AppColors.orangeLight,
                              child: const Icon(Icons.fastfood, size: 30, color: AppColors.orangePrimary)
                          ),
                        ),
                      ),
                      title: Text(cartItem.foodItem.name, style: AppTextStyles.itemName.copyWith(fontSize: 16)),
                      subtitle: Text('Qty: ${cartItem.quantity}  x  ₹${cartItem.foodItem.price.toStringAsFixed(2)}', style: AppTextStyles.subtitleBlack.copyWith(fontSize: 13)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.orangeDark, size: 26),
                            onPressed: () => cartProvider.removeItem(cartItem.foodItem.id),
                            padding: const EdgeInsets.all(4), // Reduced padding
                            constraints: const BoxConstraints(),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Text(cartItem.quantity.toString(), style: AppTextStyles.stylishBlackBold.copyWith(fontSize: 17)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.orangeDark, size: 26),
                            onPressed: () => cartProvider.addItem(cartItem.foodItem),
                            padding: const EdgeInsets.all(4), // Reduced padding
                            constraints: const BoxConstraints(),
                          ),
                          IconButton( // Moved delete to be more accessible if needed
                            icon: Icon(Icons.delete_outline, color: Colors.redAccent[400], size: 26),
                            onPressed: () => cartProvider.removeSingleItemCompletely(cartItem.foodItem.id),
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(color: AppColors.appWhite, thickness: 0.5),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount:', style: AppTextStyles.stylishWhiteBold.copyWith(fontSize: 20)),
                  Text('₹${cartProvider.totalAmount.toStringAsFixed(2)}', style: AppTextStyles.stylishWhiteBold.copyWith(fontSize: 20, color: AppColors.orangeLight)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isPlacingOrder
                    ? Container(width: 24, height: 24, padding: const EdgeInsets.all(2.0), child: const CircularProgressIndicator(color: AppColors.appWhite, strokeWidth: 3))
                    : const Icon(Icons.payment_rounded, color: AppColors.appWhite),
                label: Text(_isPlacingOrder ? 'PLACING ORDER...' : 'PLACE ORDER', style: AppTextStyles.stylishWhiteBold.copyWith(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appBlack,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
 // Style for disabled state
                ),
                onPressed: (userId != null && cartProvider.itemCount > 0 && !_isPlacingOrder)
                    ? () => _placeOrder(cartProvider, userId)
                    : null, // Button is disabled if no user, empty cart, or placing order
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1,
        onTap: _onNavItemTapped,
      ),
    );
  }
}