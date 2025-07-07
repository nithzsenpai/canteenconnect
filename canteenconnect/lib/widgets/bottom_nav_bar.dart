
// ignore_for_file: unused_import

import 'package:cafeteria_app/providers/cart_provider.dart';
import 'package:cafeteria_app/screens/cart_screen.dart';
import 'package:cafeteria_app/screens/home_screen.dart';
import 'package:cafeteria_app/screens/profile_screen.dart';
import 'package:cafeteria_app/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    int totalCartItems = cartProvider.totalQuantity;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: AppColors.appBlack,
      selectedItemColor: AppColors.orangePrimary,
      unselectedItemColor: AppColors.appWhite.withOpacity(0.7),
      type: BottomNavigationBarType.fixed, // Ensures all items are visible
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_cart),
              if (totalCartItems > 0)
                Positioned(
                  right: -8,
                  top: -8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$totalCartItems',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: 'Cart',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

//2 How to use it in screens like HomeScreen:
// int _currentIndex = 0;
// final List<Widget> _screens = [
//   HomeScreenContent(), // Your actual home screen content
//   CartScreen(),
//   ProfileScreen(),
// ];

// bottomNavigationBar: CustomBottomNavBar(
//   currentIndex: _currentIndex,
//   onTap: (index) {
//     setState(() {
//       _currentIndex = index;
//     });
//     // Optional: Use Navigator if you want full page transitions
//     // instead of just changing the body.
//     // if (index == 0 && ModalRoute.of(context)!.settings.name != '/home') {
//     //   Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
//     // } else if (index == 1 && ModalRoute.of(context)!.settings.name != '/cart') {
//     //   Navigator.pushNamed(context, '/cart');
//     // } else if (index == 2 && ModalRoute.of(context)!.settings.name != '/profile') {
//     //   Navigator.pushNamed(context, '/profile');
//     // }
//   },
// ),
// body: _screens[_currentIndex], // If not using full page navigation
