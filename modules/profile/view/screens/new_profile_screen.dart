import 'package:adgo_mobile/modules/profile/view/screens/edit_profile_screen.dart';
import 'package:adgo_mobile/modules/profile/view/screens/helpSup_screen.dart';
import 'package:adgo_mobile/modules/profile/view/screens/video_upload_test.dart';
import 'package:adgo_mobile/modules/subscription/view/screens/subscription_screen.dart';
import 'package:adgo_mobile/services/repositories/user_repository.dart';
import 'package:adgo_mobile/services/services/video_suggestion_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adgo_mobile/themes/Utils.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../routes/routes.dart';
import 'package:adgo_mobile/modules/auth/view/controllers/auth_controller.dart';
import 'package:adgo_mobile/modules/video_feed/view/controllers/video_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = false;
  String? _profileImageUrl;
  String? _userName;
  String? _userEmail;
  final UserRepository _userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      print('Loading profile for userId: $userId');
      
      if (userId == null) return;

      // Get user details from backend
      final userResponse = await _userRepository.getUserByIds(userIds: [userId]);
      
      if (userResponse.statusCode != 200 || userResponse.data.isEmpty) return;

      final userData = userResponse.data[0];
      final profilePicKey = userData['profilePictureOBjectKey'];
      
      // Update user info
      if (mounted) {
        setState(() {
          _userName = userData['userName']?.toString();
          _userEmail = userData['email']?.toString();
        });
      }
      
      // Get profile picture if available
      if (profilePicKey != null && 
          profilePicKey.toString().trim().isNotEmpty) {
        try {
          final picResponse = await _userRepository.getProfilePicDownloadUrl(
            userId: userId,
            profilePicKey: profilePicKey.toString(),
          );
          
          if (picResponse.statusCode == 200 && mounted) {
            // Simplified response parsing
            final responseData = picResponse.data;
            final downloadUrl = responseData is String 
                ? responseData
                : responseData['downloadUrl']?.toString() ?? 
                  responseData['url']?.toString();
            
            if (downloadUrl != null) {
              setState(() {
                _profileImageUrl = downloadUrl;
              });
            }
          }
        } catch (imageError) {
          // Log image loading error but don't fail the whole profile load
          debugPrint('Failed to load profile image: $imageError');
        }
      }
    } catch (e) {
      // Log error for debugging
      debugPrint('Failed to load user profile: $e');
      
      // Optional: Show user-friendly message in development
      if (mounted) {
        // You could add a snackbar here if needed for debugging
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Failed to load profile data')),
        // );
      }
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _logoutUser(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _resetPasswordConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Reset Password'),
          content: const Text('Are you sure you want to reset your password?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _resetPassword(context);
              },
              child: const Text('Reset Password'),
            ),
          ],
        );
      },
    );
  }

  void _logoutUser(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? username = prefs.getString('username');

      final isSuccess = await ref.read(signOutProvider(username!).future);
      if (isSuccess) {
        // Clear video cache on logout
        try {
          final videoService = VideoSuggestionService();
          await videoService.clearCache();
        } catch (e) {
          print('Failed to clear video cache: $e');
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Sign out successful")));
          GoRouter.of(context).go(Routes.login);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sign out failed")),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Something went wrong: $error")));
        return;
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetPassword(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    if (mounted) {
      GoRouter.of(context).push(Routes.sendVerificationCodeScreen, extra: username);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Header section
              Container(
                padding: const EdgeInsets.all(20),
                color: whiteColor,
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    children: [
                       Row(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _profileImageUrl != null 
                              ? NetworkImage(_profileImageUrl!)
                              : null,
                            child: _profileImageUrl == null 
                              ? Icon(
                                  Icons.person,
                                  size: 50,
                                  color: primaryDarkColor.withOpacity(0.6),
                                )
                              : null,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userName ?? "",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: primaryDarkColor,
                                  ),
                                ),
                                Text(
                                  _userEmail ?? "",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: primaryDarkColor.withAlpha((0.8 * 255).toInt()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Edit Profile Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ),
                            );
                            // Refresh profile if edit was successful
                            if (result == true) {
                              _loadUserProfile();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: primaryDarkColor.withAlpha((0.3 * 255).toInt())),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "Edit Profile",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Settings list (scrollable)
              Expanded(
                child: Container(
                  color: whiteColor,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Account section header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "ACCOUNT",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: primaryDarkColor.withAlpha((0.3 * 255).toInt()),
                          ),
                        ),
                      ),

                      // Account section items
                      _buildSettingItem(Icons.shop, "Shop settings"),
                      _buildSettingItem(Icons.payment, "Payment Methods"),
                      _buildSettingItem(Icons.subscriptions, "Subscriptions",
                          onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SubscriptionScreen(),
                          ),
                        );
                      }),
                      _buildSettingItem(Icons.help, "Help & Support",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpSupportPage(),
                          ),
                        );
                      }),
                      _buildSettingItem(Icons.settings, "App Settings"),
                      _buildSettingItem(Icons.password, "Reset Password",
                          onTap: () {
                        _resetPasswordConfirmationDialog(context);
                      }),
                      _buildSettingItem(Icons.delete_forever, "Delete Account",
                          textColor: Colors.red[500]),
                      _buildSettingItem(Icons.logout, "Log Out",
                          textColor: Colors.red[500], onTap: () {
                        _showLogoutConfirmationDialog(context);
                      }),
                      _buildSettingItem(Icons.logout, "Test Video Upload",
                          textColor: Colors.red[500], onTap: () {
                            _uploadTestVidoe(context);
                          }),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading) 
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }

  // Helper method to build setting items
  Widget _buildSettingItem(IconData icon, String title,
      {Color? textColor, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: whiteColor,
          border: Border(
            bottom: BorderSide(
              color: whiteColor,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: textColor ?? primaryDarkColor.withAlpha((0.8 * 255).toInt()),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor ?? primaryDarkColor.withAlpha((0.8 * 255).toInt()),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: primaryDarkColor.withAlpha((0.3 * 255).toInt()),
            ),
          ],
        ),
      ),
    );
  }

  void _uploadTestVidoe(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VideoUploadTestScreen(),
      ),
    );
  }
}