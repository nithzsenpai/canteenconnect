
import 'package:cafeteria_app/providers/auth_provider.dart' as MyAppAuthProvider;
import 'package:cafeteria_app/screens/home_screen.dart';
import 'package:cafeteria_app/screens/signup_screen.dart';
import 'package:cafeteria_app/utils/app_colors.dart';
import 'package:cafeteria_app/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<MyAppAuthProvider.AuthProvider>(context, listen: false);
      bool success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
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
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg11.jpg', // Provide your background image
              fit: BoxFit.cover,
            ),
          ),
          // Login Form
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
                      'Login',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.pageTitle.copyWith(color: const Color.fromARGB(255, 0, 0, 0)), // Stylish white
                    ),
                    const SizedBox(height: 40),
                    // Email TextField
                    TextFormField(
                      controller: _emailController,
                      style: AppTextStyles.stylishWhiteInput,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: AppTextStyles.stylishWhiteInput.copyWith(color: Colors.white70),
                        prefixIcon: const Icon(Icons.email, color: AppColors.appWhite),
                        filled: true,
                        fillColor: AppColors.appBlack.withOpacity(0.7),
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
                    const SizedBox(height: 20),
                    // Password TextField
                    TextFormField(
                      controller: _passwordController,
                      style: AppTextStyles.stylishWhiteInput,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: AppTextStyles.stylishWhiteInput.copyWith(color: Colors.white70),
                        prefixIcon: const Icon(Icons.lock, color: AppColors.appWhite),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.appWhite,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                        filled: true,
                        fillColor: AppColors.appBlack.withOpacity(0.7),
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
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement Forgot Password
                           _showForgotPasswordDialog();
                        },
                        child: Text(
                          'Forgot Password?',
                          style: AppTextStyles.stylishBlackInput.copyWith(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    authProvider.isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.orangePrimary))
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orangePrimary,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              textStyle: AppTextStyles.stylishWhiteBold,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _loginUser,
                            child: const Text('LOGIN'),
                          ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ", style: AppTextStyles.stylishBlackInput.copyWith(fontSize: 15)),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUpScreen()),
                            );
                          },
                          child: Text(
                            'Sign Up',
                            style: AppTextStyles.stylishWhiteBold.copyWith(
                              fontSize: 14,
                              color: const Color.fromARGB(255, 0, 0, 0),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
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

  void _showForgotPasswordDialog() {
    final _emailForgotController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Forgot Password"),
        content: TextField(
          controller: _emailForgotController,
          decoration: const InputDecoration(hintText: "Enter your email"),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              if (_emailForgotController.text.isNotEmpty) {
                final authProvider = Provider.of<MyAppAuthProvider.AuthProvider>(context, listen: false);
                bool success = await authProvider.sendPasswordReset(_emailForgotController.text.trim());
                Navigator.of(context).pop(); // Close dialog
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password reset email sent.")),
                  );
                } else if (mounted && authProvider.errorMessage != null) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(authProvider.errorMessage!)),
                  );
                }
              }
            },
            child: const Text("Send Reset Email"),
          ),
        ],
      ),
    );
  }
}
