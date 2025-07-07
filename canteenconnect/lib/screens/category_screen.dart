import 'package:cafeteria_app/models/food_item_model.dart';
import 'package:cafeteria_app/providers/cart_provider.dart';
import 'package:cafeteria_app/screens/cart_screen.dart';
import 'package:cafeteria_app/screens/home_screen.dart';
import 'package:cafeteria_app/screens/profile_screen.dart';
import 'package:cafeteria_app/services/firestore_service.dart';
import 'package:cafeteria_app/utils/app_colors.dart';
import 'package:cafeteria_app/utils/app_text_styles.dart';
import 'package:cafeteria_app/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatefulWidget {
  final String categoryName;
  const CategoryScreen({super.key, required this.categoryName});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<String> _allCategories = []; // For top quick links

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      List<String> fetchedCategories = await _firestoreService.getCategories();
      if (mounted) {
        setState(() {
          _allCategories = fetchedCategories;
        });
      }
    } catch (e) {
      print("Error loading categories: $e");
    }
  }

  void _onNavItemTapped(int index) {
    if (index == 0) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => HomeScreen()), (route) => false);
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => CartScreen()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName, style: const TextStyle(color: AppColors.appWhite)),
        backgroundColor: AppColors.orangePrimary, // Or use orange gradient
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.orangeGradient)),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.lightOrangeGradient),
        child: Column(
          children: [
            // Top quick categories links
            if (_allCategories.isNotEmpty)
              Container(
                height: 50,
                color: AppColors.orangeLight.withOpacity(0.5),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _allCategories.length,
                  itemBuilder: (context, index) {
                    final cat = _allCategories[index];
                    bool isSelected = cat == widget.categoryName;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: ChoiceChip(
                        label: Text(cat, style: TextStyle(color: isSelected ? AppColors.appWhite : AppColors.appBlack)),
                        selected: isSelected,
                        selectedColor: AppColors.orangeDark,
                        backgroundColor: AppColors.appWhite,
                        onSelected: (selected) {
                          if (selected && !isSelected) { // Navigate only if different category is chosen
                            Navigator.pushReplacement( // Replace to avoid stacking same category pages
                              context,
                              MaterialPageRoute(builder: (context) => CategoryScreen(categoryName: cat)),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),

            // Food items list for the current category
            Expanded(
              child: StreamBuilder<List<FoodItem>>(
                stream: _firestoreService.getMenuItemsByCategory(widget.categoryName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.orangeDark));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: AppColors.appBlack)));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No items in ${widget.categoryName}', style: const TextStyle(color: AppColors.appBlack)));
                  }

                  final items = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildFoodListItem(context, item); // Similar to FoodItemCard in HomeScreen
                    },
                  );
                },
              ),
            ),
            // Proceed to Checkout Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appBlack,
                  foregroundColor: AppColors.appWhite,
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: AppTextStyles.stylishWhiteBold,
                ),
                onPressed: () {
                   final cartProvider = Provider.of<CartProvider>(context, listen: false);
                   if (cartProvider.itemCount > 0) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => CartScreen()));
                   } else {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text("Your cart is empty! Add some items first."))
                     );
                   }
                },
                child: const Text('PROCEED TO CHECKOUT'),
              ),
            ),
          ],
        ),
      ),
       bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0, // Or determine based on route if you want it to highlight "Home"
        onTap: _onNavItemTapped,
      ),
    );
  }

  Widget _buildFoodListItem(BuildContext context, FoodItem item) {
    final cart = Provider.of<CartProvider>(context);
    final quantityInCart = cart.getQuantity(item.id);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      color: AppColors.appWhite.withOpacity(0.85),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrl.isNotEmpty ? item.imageUrl : 'https://via.placeholder.com/80x80',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, st) => const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(item.name, style: AppTextStyles.stylishBlackBold.copyWith(fontSize: 17)),
            ),
            const SizedBox(width: 10),
            Text("₹${item.price.toStringAsFixed(2)}", style: AppTextStyles.stylishBlackBold.copyWith(fontSize: 16, color: AppColors.orangeDark)),
            const SizedBox(width: 15),
            // Plus Minus controls
            if (quantityInCart == 0)
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.orangePrimary, size: 30),
                onPressed: () => cart.addItem(item),
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.orangeDark, size: 28),
                    onPressed: () => cart.removeItem(item.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("$quantityInCart", style: AppTextStyles.stylishBlackBold.copyWith(fontSize: 18)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.orangeDark, size: 28),
                    onPressed: () => cart.addItem(item),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}