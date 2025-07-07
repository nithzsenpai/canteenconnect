import 'package:cafeteria_app/models/food_item_model.dart';
import 'package:cafeteria_app/providers/cart_provider.dart';
import 'package:cafeteria_app/screens/cart_screen.dart';
import 'package:cafeteria_app/screens/category_screen.dart';
import 'package:cafeteria_app/screens/profile_screen.dart';
// Make sure you have an OrderHistoryScreen if your BottomNavBar implies it
 // ignore: unused_import
 import 'package:cafeteria_app/screens/order_history_screen.dart';
import 'package:cafeteria_app/services/firestore_service.dart';
import 'package:cafeteria_app/utils/app_colors.dart';
import 'package:cafeteria_app/utils/app_text_styles.dart';
import 'package:cafeteria_app/widgets/bottom_nav_bar.dart'; // Assuming this is your custom widget

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0; // This state variable controls the active tab for CustomBottomNavBar
  final FirestoreService _firestoreService = FirestoreService();
  List<String> _categories = [];
  List<FoodItem> _recommendations = [];
  List<FoodItem> _allMenuItems = [];
  List<FoodItem> _searchResults = [];
  final TextEditingController _searchController = TextEditingController(); // Made final

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (!mounted) return; // Ensure widget is still mounted
    String query = _searchController.text.toLowerCase();
    setState(() {
      _searchResults = query.isEmpty
          ? []
          : _allMenuItems.where((item) => item.name.toLowerCase().contains(query)).toList();
    });
  }

  Future<void> _loadData() async {
    try {
      // Fetch categories first
      List<String> fetchedCategories = await _firestoreService.getCategories();
      if (mounted) {
        setState(() {
          _categories = fetchedCategories;
        });
      }

      // Then listen to menu items
      _firestoreService.getMenuItems().listen((items) {
        if (mounted) {
          setState(() {
            _allMenuItems = items;
            // Update recommendations based on all items or a specific logic
            _recommendations = items.where((item) => item.category == "Featured" || item.category == _categories.firstOrNull).take(5).toList(); // Example logic
            if(_recommendations.isEmpty && items.isNotEmpty) {
              _recommendations = items.take(5).toList(); // Fallback
            }
          });
        }
      });
    } catch (e) {
      print("Error loading home data: $e");
      if (mounted) {
        // Optionally show a snackbar or error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load data: ${e.toString()}")),
        );
      }
    }
  }

  void _onNavItemTapped(int index) {
    // This function is called when an item in CustomBottomNavBar is tapped.
    // It should handle navigation OR update the currentIndex if HomeScreen
    // itself is supposed to change its body based on the tab.

    // If CustomBottomNavBar is for navigating to completely different screens:
    if (index == 0) {
      // HomeScreen is index 0, so if we are already here,
      // update currentIndex for the visual feedback on the NavBar.
      // No actual navigation needed if this IS the home screen.
      if (currentIndex != index) { // Only setState if index actually changed
        setState(() {
          currentIndex = index;
        });
      }
    } else if (index == 1) { // Assuming CartScreen
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
    } else if (index == 2) { // Assuming ProfileScreen
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
    }
    // Add other navigation paths based on your CustomBottomNavBar's items
    // e.g., else if (index == 3) { Navigator.push(context, MaterialPageRoute(builder: (_) => OrderHistoryScreen())); }
  }


  Widget _buildHomeScreenContent(BuildContext context) {
    // ... your existing _buildHomeScreenContent code ...
    // (No changes needed in this method based on the error)
     return Container(
      decoration: const BoxDecoration(gradient: AppColors.orangeGradient),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            floating: true,
            pinned: false,
            elevation: 0,
            title: Container(
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.appWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.appBlack),
                decoration: InputDecoration(
                  hintText: 'Search for food...',
                  hintStyle: TextStyle(color: AppColors.appBlack.withOpacity(0.6)),
                  prefixIcon: Icon(Icons.search, color: AppColors.appBlack.withOpacity(0.8)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
                ),
              ),
            ),
          ),

          if (_searchController.text.isNotEmpty && _searchResults.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Text("Search Results", style: AppTextStyles.stylishWhiteBold.copyWith(fontSize: 22)),
              ),
            ),
          if (_searchController.text.isNotEmpty && _searchResults.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _searchResults[index];
                  return _buildFoodItemCard(context, item);
                },
                childCount: _searchResults.length,
              ),
            ),
          if (_searchController.text.isNotEmpty && _searchResults.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text("No results found for '${_searchController.text}'",
                      style: TextStyle(color: AppColors.appWhite)),
                ),
              ),
            ),

          if (_searchController.text.isEmpty) ...[ // Use collection-if for multiple slivers
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("What's your mood?",
                    style: AppTextStyles.stylishWhiteBold.copyWith(fontSize: 22)),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                height: 120,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _categories.isEmpty && _allMenuItems.isEmpty // check if still loading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.appWhite))
                    : _categories.isEmpty // If categories specifically are empty after load
                        ? const Center(child: Text("No categories found.", style: TextStyle(color: AppColors.appWhite)))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              String category = _categories[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CategoryScreen(categoryName: category),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: AppColors.appWhite,
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  child: Container(
                                    width: 100,
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.restaurant, // Consider dynamic icons based on category
                                            color: AppColors.orangePrimary, size: 40),
                                        const SizedBox(height: 6),
                                        Text(category,
                                            textAlign: TextAlign.center,
                                            style: AppTextStyles.stylishBlackBold.copyWith(fontSize: 13),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
                child: Text("Recommendations",
                    style: AppTextStyles.stylishWhiteBold.copyWith(fontSize: 22)),
              ),
            ),
            _recommendations.isEmpty && _allMenuItems.isEmpty // Still loading
                ? const SliverToBoxAdapter(child: Center(child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: AppColors.appWhite),
                  )))
                : _recommendations.isEmpty // No recommendations after load
                    ? const SliverToBoxAdapter(child: Center(child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("No recommendations available.", style: TextStyle(color: AppColors.appWhite)),
                      )))
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = _recommendations[index];
                            return _buildFoodItemCard(context, item);
                          },
                          childCount: _recommendations.length,
                        ),
                      ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)), // Bottom padding
          ],
        ],
      ),
    );
  }

  Widget _buildFoodItemCard(BuildContext context, FoodItem item) {
    // Use a Consumer for CartProvider if you only need to rebuild this part
    // Or ensure Provider.of is fine if HomeScreen rebuilds are acceptable
    final cart = Provider.of<CartProvider>(context);
    final quantityInCart = cart.getQuantity(item.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: AppColors.appWhite,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.imageUrl.isNotEmpty ? item.imageUrl : 'https://tse4.mm.bing.net/th?id=OIP.FUQCXYrVgVPcVTb_hGFCxAHaFj&pid=Api&P=0&h=180',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(width: 80, height: 80, color: Colors.grey[200], child: const Icon(Icons.broken_image, size: 40, color: Colors.grey)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: AppTextStyles.stylishBlackBold.copyWith(fontSize:18)),
                  Text("Category: ${item.category}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 15)),
                  const SizedBox(height: 5),
                  Text("₹${item.price.toStringAsFixed(2)}",
                      style: AppTextStyles.stylishBlackBold
                          .copyWith(color: AppColors.orangeDark, fontSize: 16)),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center, // Align buttons vertically
              children: [
                if (quantityInCart == 0)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_shopping_cart, size: 18),
                    label: const Text("ADD"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orangePrimary,
                      foregroundColor: AppColors.appWhite,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => cart.addItem(item),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8), // Consistent border radius
                      border: Border.all(color: AppColors.orangePrimary, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove,
                              color: AppColors.orangePrimary, size: 18),
                          onPressed: () => cart.removeItem(item.id),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Adjusted padding
                          splashRadius: 20,
                        ),
                        Padding( // Added padding for the quantity text
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text("$quantityInCart",
                              style: AppTextStyles.stylishBlackBold.copyWith(fontSize: 16)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add,
                              color: AppColors.orangePrimary, size: 18),
                          onPressed: () => cart.addItem(item),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Adjusted padding
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Cafeteria")), // Or keep AppBar within CustomScrollView
      body: _buildHomeScreenContent(context),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: currentIndex, // Pass the state variable
        onTap: _onNavItemTapped,
      ),
    );
  }
}