// lib/screens/help_screen.dart

import 'package:cafeteria_app/providers/auth_provider.dart' as MyAppAuthProvider;
import 'package:cafeteria_app/services/firestore_service.dart'; // Ensure this import is correct
import 'package:cafeteria_app/utils/app_colors.dart';
import 'package:cafeteria_app/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _questionController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService(); // Instantiation
  bool _isLoading = false;

  final List<Map<String, String>> _faqs = [
    {'q': 'How do I reset my password?', 'a': 'Go to the login page and click "Forgot Password". Follow the instructions sent to your email.'},
    {'q': 'How can I track my order?', 'a': 'Currently, order tracking is based on the estimated delivery time. We are working on live tracking!'},
    {'q': 'What are the payment options?', 'a': 'We accept Cash on Delivery and online payments (coming soon).'},
    {'q': 'How to cancel an order?', 'a': 'Please contact support immediately after placing an order if you wish to cancel.'},
  ];

  @override
  void initState() {
    super.initState();
    // Using WidgetsBinding to ensure context is available for Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // Check if widget is still mounted
        final authProvider = Provider.of<MyAppAuthProvider.AuthProvider>(context, listen: false);
        if (authProvider.user != null) {
          _emailController.text = authProvider.user!.email ?? '';
          // You might want to fetch and prefill name from a user profile if available
          // _nameController.text = authProvider.user!.displayName ?? ''; // Only if displayName is reliably set
        }
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _submitQuery() async {
    if (!(_formKey.currentState?.validate() ?? false)) return; // Added null check for currentState

    if (mounted) setState(() => _isLoading = true); // Check mounted before setState
    
    final authProvider = Provider.of<MyAppAuthProvider.AuthProvider>(context, listen: false);
    String? userId = authProvider.user?.uid;

    try {
      await _firestoreService.submitHelpQuery(
        userId: userId ?? 'guest',
        name: _nameController.text,
        email: _emailController.text,
        question: _questionController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Your query has been submitted. We'll get back to you soon!")));
        _formKey.currentState?.reset();
        _questionController.clear();
        // Only clear name and email if they were not pre-filled or if you want to clear them anyway
        // if (authProvider.user == null) { // Example condition
        //   _nameController.clear();
        //   _emailController.clear();
        // }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to submit query: $e")));
      }
      print("Error in _submitQuery: $e"); // Print error for debugging
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(color: AppColors.appWhite)),
        backgroundColor: AppColors.orangePrimary,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.orangeGradient)),
        iconTheme: const IconThemeData(color: AppColors.appWhite), // Ensure back button is white
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _faqs.length,
              itemBuilder: (context, index) {
                return Card( // Added Card for better visual separation
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  elevation: 1,
                  child: ExpansionTile(
                    iconColor: AppColors.orangePrimary,
                    collapsedIconColor: AppColors.orangePrimary,
                    title: Text(_faqs[index]['q']!, style: AppTextStyles.bodyTextBlack.copyWith(fontWeight: FontWeight.w600)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 15.0),
                        child: Text(_faqs[index]['a']!, style: AppTextStyles.bodyTextBlack.copyWith(color: Colors.grey[700])),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
           
            const SizedBox(height: 15),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      border: const OutlineInputBorder(),
                      labelStyle: AppTextStyles.bodyTextBlack,
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Your Email',
                      border: const OutlineInputBorder(),
                      labelStyle: AppTextStyles.bodyTextBlack,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your email';
                      if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      labelText: 'Your Question/Concern',
                      border: const OutlineInputBorder(),
                      labelStyle: AppTextStyles.bodyTextBlack,
                    ),
                    maxLines: 4,
                    validator: (value) => (value == null || value.isEmpty) ? 'Please describe your issue' : null,
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator(color: AppColors.orangePrimary))
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.orangePrimary,
                            foregroundColor: AppColors.appWhite,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            textStyle: AppTextStyles.stylishWhiteBold.copyWith(fontSize: 16), // Increased font size slightly
                          ),
                          onPressed: _submitQuery,
                          child: const Text('SUBMIT QUERY'),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}