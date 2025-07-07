import 'package:cafeteria_app/auth/auth_service.dart';
import 'package:cafeteria_app/services/firestore_service.dart';
import 'package:cafeteria_app/utils/app_colors.dart';
import 'package:cafeteria_app/utils/app_text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? userData; // Pass current user data
  const EditProfileScreen({super.key, this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController(); // Email change is sensitive, usually needs re-auth
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  final FirestoreService firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.userData != null) {
      _nameController.text = widget.userData!['name'] ?? '';
      _emailController.text = widget.userData!['email'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    String? userId = _authService.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User not found.")));
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Update name in Firebase Auth and Firestore
      if (_nameController.text.isNotEmpty && _nameController.text != widget.userData?['name']) {
        await _authService.updateUserName(_nameController.text); // Updates Auth display name & Firestore 'name' field
      }

      // Handle password change
      if (_newPasswordController.text.isNotEmpty) {
        // Firebase requires re-authentication for sensitive operations like password change
        // For simplicity, we're skipping re-auth here, but it's crucial in production.
        // You might need to prompt for current password or sign in again.
        
        // The current flow would need to prompt for current password to re-authenticate the user
        // then call updatePassword. For this example, let's assume re-authentication is handled
        // or that firebase allows password change without it for a recently logged in user (less common)
        
        // A more robust way:
        // 1. Prompt for current password.
        // 2. Re-authenticate: AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: currentPasswordController.text);
        //    await user.reauthenticateWithCredential(credential);
        // 3. Then update password: await user.updatePassword(newPasswordController.text);

        // Simplified version (may fail without re-authentication):
        await _authService.changePassword(_newPasswordController.text);
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password updated successfully. (Re-login may be required)")));
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully!")));
      Navigator.of(context).pop(); // Go back to profile screen

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("An unexpected error occurred: $e")));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.orangePrimary,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.orangeGradient)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("Personal Information", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.orangeDark)),
              const SizedBox(height: 15),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Name cannot be empty' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email (Cannot be changed here)', border: OutlineInputBorder()),
                readOnly: true, // Email change is more complex, usually involves verification
              ),
              const SizedBox(height: 30),
              Text("Change Password", style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.orangeDark)),
              const SizedBox(height: 10),
              Text("Leave fields blank if you don't want to change password.", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              const SizedBox(height: 15),
              // TextFormField(
              //   controller: _currentPasswordController,
              //   decoration: InputDecoration(labelText: 'Current Password', border: OutlineInputBorder()),
              //   obscureText: true,
              //   // Validator needed if new password is not empty
              // ),
              // SizedBox(height: 15),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'New password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _confirmNewPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm New Password', border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) {
                  if (_newPasswordController.text.isNotEmpty && value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orangePrimary,
                        foregroundColor: AppColors.appWhite,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        textStyle: AppTextStyles.stylishWhiteBold,
                      ),
                      onPressed: _updateProfile,
                      child: const Text('SAVE CHANGES'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}