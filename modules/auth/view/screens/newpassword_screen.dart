/*
@Author - Anuruddha
@Date - 2025/03/29
 */
import 'package:adgo_mobile/modules/auth/view/controllers/auth_controller.dart';
import 'package:adgo_mobile/modules/video_feed/view/controllers/video_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:adgo_mobile/routes/routes.dart';
import 'package:adgo_mobile/themes/utils.dart';
import 'package:adgo_mobile/widgets/customTextField.dart';
import 'package:adgo_mobile/validation/providers/password_validation_provider.dart';

class NewPasswordScreen extends ConsumerStatefulWidget {
  const NewPasswordScreen({super.key, required this.data});

  final Map<String, String> data;

  

  @override
  // ignore: library_private_types_in_public_api
  _NewPasswordScreenState createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword(BuildContext context) async {
    final String newPassword = _newPasswordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

      setState(() {
        _isLoading = true;
      });
    
    // Update the password provider with current value
    ref.read(pwProvider.notifier).state = newPassword;

    // Get password validation result
    final passwordValidation = ref.read(pwValidationProvider);

    final otp = widget.data['otp'];
    final username = widget.data['username'];

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields')),
      );
      return;
    }

    // Password validation
    if (!passwordValidation.isValid) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passwordValidation.error ?? 'Invalid password format')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (username != null && otp != null) {
    try {
      final isSuccess = await ref.read(resetPasswordProvider((username, otp, newPassword)).future);
      if (isSuccess) {
       if(mounted){
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password reset successful")));
       
       // Navigate to home first
       GoRouter.of(context).go(Routes.home);
       
       // Invalidate video providers after navigation to ensure userId is saved
       // Use a small delay to ensure SharedPreferences has flushed
       Future.delayed(const Duration(milliseconds: 100), () {
         ref.invalidate(paginatedVideoGridProvider);
         ref.invalidate(videoGridProvider);
       });
       }
      } else {
        if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset failed")),
        );
        }
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password reset failed: \$error")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    }
    else {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Invalid username or OTP')),
       );
     }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Set New Password')),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Padding(
                            padding: const EdgeInsets.fromLTRB(35, 0, 36, 50),
                            child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                        CachedNetworkImage(
                          imageUrl:
                              'https://adgo-logo-public.s3.ap-south-1.amazonaws.com/images/password.png',
                          height: 243,
                          width: 243,
                          placeholder: (context, url) => Container(
                            width: 243,
                            height: 243,
                            color: Colors.grey[200],
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error, size: 100),
                      ),
                      Text(
                          'Please Enter a New Password Below.',
                        style: TextStyle(
                          color: primaryDarkColor,
                            fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      CustomTextField(
                        onChanged: (value) {
                            ref.read(pwProvider.notifier).state = value;
                          },
                        validationProvider: pwValidationProvider,
                        keyboardType: TextInputType.visiblePassword,
                        controller: _newPasswordController,
                        obscureText: true,
                        icon: Icons.lock,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your new password';
                          }
                          return null;
                        },
                        hintText: 'New Password',
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        keyboardType: TextInputType.visiblePassword,
                        controller: _confirmPasswordController,
                        obscureText: true,
                        icon: Icons.lock,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          return null;
                        },
                        hintText: 'Confirm Password',
                      ),
                      const SizedBox(height: 45),
                        
                    ],
                  ),
                            ),
                          ),
                ),
                Padding(
                          padding: const EdgeInsets.fromLTRB(35, 0, 36, 20),
                          child: Column(
                            children: [
                              Container(
                                width: 318,
                                height: 62,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(19),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryLightColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(19),
                                    ),
                                  ),
                                  onPressed: () => _resetPassword(context),
                                  child: Text('Save',
                                      style: TextStyle(
                                          fontSize: 24, color: secondaryLightColor)),
                                ),
                              ),
                              const SizedBox(height: 20),
                              InkWell(
                                onTap: () {
                                  GoRouter.of(context).go(Routes.login);
                                },
                                child: Text(
                                  'Back to Login',
                                  style: TextStyle(
                                    color: primaryLightColor,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
              ],
            ),
        if (_isLoading)
              const LinearProgressIndicator(),
          ],
        )
      );
}
