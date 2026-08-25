/*
@Author - Anuruddha
@Date - 2025/03/29
 */
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:adgo_mobile/routes/routes.dart';
import 'package:adgo_mobile/themes/utils.dart';
import 'package:adgo_mobile/widgets/customTextField.dart';
import 'package:adgo_mobile/validation/providers/email_validation_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final String email = _emailController.text.trim();

    setState(() {
      _isLoading = true;
    });

    if (email.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

  // Get email validation result
    final emailValidation = ref.read(emailValidationProvider);
    
    // Check email validation
    if (!emailValidation.isValid) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailValidation.error ?? 'Invalid email')),
      );
      return;
    }

  // Proceed with reset password flow
    setState(() {
      _isLoading = false;
    });    
   
   if (mounted) {
      GoRouter.of(context).push(Routes.sendVerificationCodeScreen, extra: _emailController.text);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Reset Password')),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(35, 0, 36, 50),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        imageUrl: 'https://adgo-logo-public.s3.ap-south-1.amazonaws.com/images/fogotpw.png',
                        width: 243,
                        height: 243,
                        placeholder: (context, url) => Container(
                          width: 243,
                          height: 243,
                          color: Colors.grey[200],
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error, size: 100),
                      ),
                      Text(
                        'Forgot your password?',
                        style: TextStyle(
                          color: primaryDarkColor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Enter your email address below to receive a OTP to reset your password',
                        style: TextStyle(
                          color:
                              primaryDarkColor.withAlpha((0.3 * 255).toInt()),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 45),
                      CustomTextField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        icon: Icons.email_sharp,
                        onChanged: (value) {
                              ref.read(emailProvider.notifier).state = value;
                            },
                        validationProvider: emailValidationProvider,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        hintText: 'Email ID',
                      ),
                      const SizedBox(height: 45),
                      
                      
                    ],
                  ),
                ),
              ),
            ),
            Column(
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
                    onPressed: () => _resetPassword(),
                    child: Text('Reset Password',
                        style: TextStyle(
                            fontSize: 24, color: secondaryLightColor)),
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    GoRouter.of(context).pop();
                  },
                  child: Text(
                    'Back to Profile',
                    style: TextStyle(
                      color: primaryLightColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          if (_isLoading)
              const LinearProgressIndicator(),
          ],
        ),
      );
}
