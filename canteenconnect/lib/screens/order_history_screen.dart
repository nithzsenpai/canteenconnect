
// lib/screens/order_history_screen.dart (Assuming this is the file)

// Ensure this path and prefix are correct
import 'package:cafeteria_app/models/order_model.dart' as app_order;
import 'package:cafeteria_app/providers/auth_provider.dart' as MyAppAuthProvider;
// CORRECT IMPORT FOR FirestoreService:
import 'package:cafeteria_app/services/firestore_service.dart'; // <--- MAKE SURE THIS PATH IS CORRECT
import 'package:cafeteria_app/utils/app_colors.dart';
import 'package:cafeteria_app/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  // THIS IS THE LINE YOU MENTIONED:
  final FirestoreService _firestoreService = FirestoreService(); // This should be fine

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MyAppAuthProvider.AuthProvider>(context, listen: false);
    final userId = authProvider.user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History', style: TextStyle(color: AppColors.appWhite)),
        backgroundColor: AppColors.orangePrimary,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.orangeGradient)),
        iconTheme: const IconThemeData(color: AppColors.appWhite),
      ),
      body: userId == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text(
                    "Please log in to see order history.",
                    style: AppTextStyles.bodyTextBlack.copyWith(color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ))
          : StreamBuilder<List<app_order.Order>>(
              stream: _firestoreService.getOrderHistory(userId), // _firestoreService is used here
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.orangePrimary));
                }
                if (snapshot.hasError) {
                  print("OrderHistoryScreen Error: ${snapshot.error}");
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Error loading order history. Please try again later.\nDetails: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyTextBlack.copyWith(color: Colors.red[700]),
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 50, color: Colors.grey),
                        const SizedBox(height: 10),
                        Text(
                          'No orders found.',
                          style: AppTextStyles.bodyTextBlack.copyWith(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Looks like you haven\'t placed any orders yet!',
                           style: AppTextStyles.subtitleBlack.copyWith(color: Colors.grey[600]),
                           textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  );
                }

                final orders = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.orangeLight,
                          child: Text(
                            (index + 1).toString(),
                            style: const TextStyle(color: AppColors.orangeDark, fontWeight: FontWeight.bold)
                          )
                        ),
                        title: Text(
                          'Order ID: ${order.id != null && order.id!.length > 8 ? order.id!.substring(0, 8) : order.id ?? 'N/A'}...',
                          style: AppTextStyles.itemName.copyWith(fontWeight: FontWeight.bold)
                        ),
                        subtitle: Text(
                          'Date: ${DateFormat.yMMMd().add_jm().format(order.orderDate)}\nStatus: ${order.status}',
                          style: AppTextStyles.subtitleBlack.copyWith(fontSize: 13),
                        ),
                        trailing: Text(
                          '₹${order.totalAmount.toStringAsFixed(2)}',
                          style: AppTextStyles.priceText.copyWith(fontSize: 15)
                        ),
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Items:", style: AppTextStyles.bodyTextBlack.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 5),
                                ...order.items.map((item) {
                                  return ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        item.foodItem.imageUrl.isNotEmpty ? item.foodItem.imageUrl : 'https://via.placeholder.com/50',
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, o, s) => const Icon(Icons.fastfood, size: 40, color: AppColors.orangeLight),
                                      ),
                                    ),
                                    title: Text("${item.foodItem.name} (x${item.quantity})", style: AppTextStyles.bodyTextBlack.copyWith(fontSize: 14)),
                                    trailing: Text("₹${(item.foodItem.price * item.quantity).toStringAsFixed(2)}", style: AppTextStyles.bodyTextBlack.copyWith(fontSize: 14)),
                                  );
                                }).toList(),
                                const Divider(height: 20),
                                Text("Delivery Address:", style: AppTextStyles.bodyTextBlack.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(order.deliveryAddress, style: AppTextStyles.bodyTextBlack.copyWith(fontSize: 14)),
                                const SizedBox(height: 5),
                                Text("Estimated Delivery:", style: AppTextStyles.bodyTextBlack.copyWith(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(order.estimatedDeliveryTime, style: AppTextStyles.bodyTextBlack.copyWith(fontSize: 14)),
                                const SizedBox(height: 10),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}