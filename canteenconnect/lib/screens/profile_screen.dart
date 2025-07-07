import 'package:cafeteria_app/providers/auth_provider.dart' as MyAppAuthProvider; // aliased
import 'package:cafeteria_app/screens/edit_profile_screen.dart';
import 'package:cafeteria_app/screens/help_screen.dart';
import 'package:cafeteria_app/screens/login_screen.dart';
import 'package:cafeteria_app/screens/order_history_screen.dart';
import 'package:cafeteria_app/services/firestore_service.dart';
import 'package:cafeteria_app/utils/app_colors.dart';
import 'package:cafeteria_app/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final authProvider = Provider.of<MyAppAuthProvider.AuthProvider>(context, listen: false);
    if (authProvider.user != null) {
      final data = await _firestoreService.getUserProfile(authProvider.user!.uid);
      if (mounted) {
        setState(() {
          _userData = data;
        });
      }
    }
  }

  void _onNavItemTapped(int index) {
    if (index == 0) { // Home
      if (ModalRoute.of(context)?.settings.name != '/home') {
        Navigator.popUntil(context, ModalRoute.withName('/home'));
      }
    } else if (index == 1) { // Cart
      if (ModalRoute.of(context)?.settings.name != '/cart') {
        Navigator.pushNamed(context, '/cart');
      }
    } else if (index == 2) { // Profile - already here
      _loadUserProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MyAppAuthProvider.AuthProvider>(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    // Define your background image path here
    const String backgroundImagePath = 'assets/images/bg11.jpg'; // <-- REPLACE THIS

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: AppColors.appWhite, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.orangePrimary,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: AppColors.orangeGradient)),
        elevation: 0,
      ),
      // extendBodyBehindAppBar: true, // Uncomment if you want the background image to go behind the AppBar
      body: Container( // This Container will hold the background image
        width: double.infinity, // Ensure it fills the width
        height: double.infinity, // Ensure it fills the height
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(backgroundImagePath), // Your background image
            fit: BoxFit.cover, // Adjust to your needs (cover, contain, fill, etc.)
            // Optional: Add a color filter to dim the image or change its hue
            // colorFilter: ColorFilter.mode(
            //   Colors.black.withOpacity(0.3), // Example: 30% black overlay
            //   BlendMode.darken,
            // ),
          ),
        ),
        child: authProvider.user == null
            ? Center(
                child: Container( // Optional: Add a semi-transparent background to make text more readable
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      )
                    ]
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person_off_outlined, size: 70, color: AppColors.orangePrimary.withOpacity(0.9)),
                      const SizedBox(height: 20),
                      Text(
                        "You are not logged in.",
                        style: textTheme.headlineSmall?.copyWith(color: Colors.grey[800], fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orangePrimary,
                          foregroundColor: AppColors.appWhite,
                          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                           shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0)
                          )
                        ),
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (Route<dynamic> route) => false,
                            );
                        },
                        child: const Text('Login Now', style: TextStyle(fontSize: 16)),
                      )
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadUserProfile,
                color: AppColors.orangePrimary,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                  children: [
                    // User Info Header
                    if (_userData != null)
                      Card(
                        elevation: 6, // Slightly more elevation to stand out from bg
                        margin: const EdgeInsets.only(bottom: 25),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        color: Theme.of(context).cardColor.withOpacity(0.9), // Make card slightly transparent if desired
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.orangeLight.withOpacity(0.8),
                                child: Text(
                                  _userData!['name']?.substring(0, 1).toUpperCase() ?? 'U',
                                  style: TextStyle(fontSize: 40, color: AppColors.orangeDark, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Text(
                                _userData!['name'] ?? 'User Name',
                                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? AppColors.appWhite : AppColors.appBlack),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                _userData!['email'] ?? 'user@example.com',
                                style: textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (_userData == null && authProvider.user != null)
                       Center( // Make progress indicator more visible
                        child: Container(
                          padding: const EdgeInsets.all(25),
                           margin: const EdgeInsets.symmetric(vertical: 50.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(12),
                             boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                              )
                            ]
                          ),
                          child: const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.orangePrimary)),
                        ),
                      ),

                    _buildProfileOption(
                      context,
                      icon: Icons.person_outline,
                      title: 'Edit Personal Details',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(userData: _userData)))
                          .then((_) => _loadUserProfile());
                      },
                    ),
                    _buildProfileOption(
                      context,
                      icon: Icons.location_on_outlined,
                      title: 'Change Address',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Change Address Tapped (Not Implemented)")));
                      },
                    ),
                    _buildProfileOption(
                      context,
                      icon: Icons.history_edu_outlined,
                      title: 'Food Order History',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => OrderHistoryScreen()));
                      },
                    ),
                    _buildProfileOption(
                      context,
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => HelpScreen()));
                      },
                    ),
                    const SizedBox(height: 35),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout, color: AppColors.appWhite),
                      label: const Text('Logout', style: TextStyle(color: AppColors.appWhite, fontSize: 17, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appBlack.withOpacity(0.85),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0)
                        ),
                        elevation: 3,
                      ),
                      onPressed: () async {
                        await authProvider.signOut();
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (Route<dynamic> route) => false,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: _onNavItemTapped,
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(0.9), // Make card slightly transparent
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.orangePrimary.withOpacity(0.08),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.orangeLight.withOpacity(0.25), // Slightly more opaque icon bg
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.orangePrimary, size: 24),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).brightness == Brightness.dark ? AppColors.appWhite.withOpacity(0.9) : AppColors.appBlack.withOpacity(0.9) // Ensure text readability
                  )
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey[500]),
            ],
          ),
        ),
      ),
    );
  }
}