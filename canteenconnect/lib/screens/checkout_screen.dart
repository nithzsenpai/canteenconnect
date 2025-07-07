import 'package:cafeteria_app/screens/home_screen.dart';
import 'package:cafeteria_app/utils/app_colors.dart';
import 'package:cafeteria_app/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
// Optional: If you want to use a Lottie animation for the tick
// import 'package:lottie/lottie.dart';

class CheckoutScreen extends StatefulWidget {
  final String estimatedDeliveryTime;

  const CheckoutScreen({
    super.key,
    required this.estimatedDeliveryTime,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700), // Duration of the tick animation
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut, // Gives a nice bouncy effect
      ),
    );

    _animationController.forward(); // Start the animation

    // Navigate to HomeScreen after a delay
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) { // Check if the widget is still in the tree
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false, // Remove all previous routes
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.orangePrimary, // Full screen orange background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Tick Animation
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: const BoxDecoration(
                    color: AppColors.appWhite, // White circle background for the tick
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                    ]
                  ),
                  child: const Icon(
                    Icons.check_rounded, // Using a Material check icon
                    color: Colors.green, // Green color for the tick
                    size: 100.0,
                  ),
                ),
              ),
              // --- OR if using Lottie ---
              // Lottie.asset(
              //   'assets/animations/your_tick_animation.json', // Replace with your Lottie file path
              //   width: 150,
              //   height: 150,
              //   repeat: false,
              //   controller: _animationController, // You might need to adjust Lottie setup
              //   onLoaded: (composition) {
              //     _animationController
              //       ..duration = composition.duration
              //       ..forward();
              //   },
              // ),
              const SizedBox(height: 40),
              Text(
                'Your order is placed successfully!',
                textAlign: TextAlign.center,
                style: AppTextStyles.stylishWhiteBold.copyWith(
                  fontSize: 26,
                  shadows: [
                     Shadow( // Adding a subtle shadow to white text on orange
                      offset: Offset(1.0, 1.0),
                      blurRadius: 2.0,
                      color: AppColors.appBlack.withOpacity(0.3),
                    ),
                  ]
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Estimated Delivery Time: ${widget.estimatedDeliveryTime}',
                textAlign: TextAlign.center,
                style: AppTextStyles.stylishWhiteInput.copyWith(
                  fontSize: 18,
                   shadows: [
                     Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 2.0,
                      color: AppColors.appBlack.withOpacity(0.2),
                    ),
                  ]
                ),
              ),
              const SizedBox(height: 50),
               Text(
                'Redirecting to home page...',
                style: AppTextStyles.stylishWhiteInput.copyWith(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AppColors.appWhite.withOpacity(0.8)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}