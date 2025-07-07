import 'package:cafeteria_app/providers/auth_provider.dart' as MyAppAuthProvider;
import 'package:cafeteria_app/screens/home_screen.dart';
import 'package:cafeteria_app/utils/app_colors.dart';
import 'package:cafeteria_app/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }
  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }


  Future<void> _signUpUser() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<MyAppAuthProvider.AuthProvider>(context, listen: false);
      bool success = await authProvider.signUp(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (success && mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false, // Remove all previous routes
        );
      } else if (mounted && authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage!)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MyAppAuthProvider.AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg11.jpg', // Provide a different background or reuse
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                     Text(
                      'Create Account',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.pageTitle.copyWith(color: AppColors.appBlack, fontSize: 28),
                    ),
                    const SizedBox(height: 30),
                    // Name TextField
                    TextFormField(
                      controller: _nameController,
                      style: AppTextStyles.stylishBlackInput,
                      decoration: InputDecoration(
                        hintText: 'Full Name',
                        hintStyle: AppTextStyles.stylishBlackInput.copyWith(color: Colors.black54),
                        prefixIcon: const Icon(Icons.person, color: AppColors.appBlack),
                        filled: true,
                        fillColor: AppColors.appWhite.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    // Email TextField
                    TextFormField(
                      controller: _emailController,
                      style: AppTextStyles.stylishBlackInput,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: AppTextStyles.stylishBlackInput.copyWith(color: Colors.black54),
                        prefixIcon: const Icon(Icons.email, color: AppColors.appBlack),
                        filled: true,
                        fillColor: AppColors.appWhite.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    // Password TextField
                    TextFormField(
                      controller: _passwordController,
                      style: AppTextStyles.stylishBlackInput,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: AppTextStyles.stylishBlackInput.copyWith(color: Colors.black54),
                        prefixIcon: const Icon(Icons.lock, color: AppColors.appBlack),
                         suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.appBlack,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                        filled: true,
                        fillColor: AppColors.appWhite.withOpacity(0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    // Confirm Password TextField
                    TextFormField(
                      controller: _confirmPasswordController,
                      style: AppTextStyles.stylishBlackInput,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        hintStyle: AppTextStyles.stylishBlackInput.copyWith(color: Colors.black54),
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.appBlack),
                         suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.appBlack,
                          ),
                          onPressed: _toggleConfirmPasswordVisibility,
                        ),
                        filled: true,
                        fillColor: AppColors.appWhite.withOpacity(0.9),
                         border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                     authProvider.isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.orangePrimary))
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orangePrimary, // Or use white button as requested
                              // backgroundColor: AppColors.appWhite,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              textStyle: AppTextStyles.stylishWhiteBold,
                              // textStyle: AppTextStyles.stylishBlackBold, // If white button
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _signUpUser,
                            child: const Text('SIGN UP'),
                            // child: Text('SIGN UP', style: AppTextStyles.stylishBlackBold), // If white button
                          ),
                    const SizedBox(height: 15),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(), // Go back to login
                      child: Text(
                        'Already have an account? Login',
                        style: AppTextStyles.stylishBlackInput.copyWith(
                          fontSize: 16,
                          decoration: TextDecoration.underline
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}