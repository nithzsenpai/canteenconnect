import 'package:cafeteria_app/screens/login_screen.dart';
import 'package:cafeteria_app/utils/app_colors.dart';
import 'package:cafeteria_app/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.orangeGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Replace with your logo (now a PNG with transparency)
              Image.asset('assets/images/logo.png', height: 150, width: 150,), // <--- CHANGED TO .png
             SizedBox(height: 50),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: AppTextStyles.stylishBlackBold.copyWith(fontSize: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)
                  )
                ),
                child: const Text('Get Started'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}