// ignore_for_file: library_private_types_in_public_api

/*
@Author - Anuruddha
@Date - 2025/02/11
 */
import 'package:adgo_mobile/modules/auth/view/controllers/auth_controller.dart';
import 'package:adgo_mobile/modules/video_feed/view/controllers/video_controller.dart';
import 'package:adgo_mobile/themes/utils.dart';
import 'package:adgo_mobile/validation/providers/email_validation_provider.dart';
import 'package:adgo_mobile/validation/providers/password_validation_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:adgo_mobile/routes/routes.dart';
import '../../../../widgets/customTextField.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    setState(() {
        _isLoading = true;
      });


  if(email.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
  final emailValidation = ref.read(emailValidationProvider);
  final passwordValidation = ref.read(pwValidationProvider);

  
  if (!emailValidation.isValid) {  
     setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(emailValidation.error ?? 'Invalid email')),
      );
    return;
  }

if (!passwordValidation.isValid) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text(passwordValidation.error ?? 'Invalid password')),
      );
      return;
    }


    try {
      final isSuccess = await ref.read(signInUserProvider((email, password)).future);
      if (isSuccess) {
       if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sign in successful")));
          
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sign in failed")));
        }
      }
    } catch (error) {
      if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sign in failed: $error")));
          return;
        }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  
  }


  

  @override
  Widget build(BuildContext context) => Scaffold(
        extendBody: true,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(35, 20, 36, 0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CachedNetworkImage(
                              imageUrl: 'https://adgo-logo-public.s3.ap-south-1.amazonaws.com/images/otp.png',
                              width: 200,
                              height: 200,
                              placeholder: (context, url) => Container(
                                width: 200,
                                height: 200,
                                color: Colors.grey[200],
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Login to Your Account',
                              style: TextStyle(
                                color: primaryDarkColor,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            CustomTextField(
                              keyboardType: TextInputType.visiblePassword,
                              onChanged: (value) {
                                ref.read(emailProvider.notifier).state = value;
                              },
                              validationProvider: emailValidationProvider,
                              controller: _emailController,
                              icon: Icons.email_sharp,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                return null;
                              },
                              hintText: 'Email ID',
                            ),
                            const SizedBox(height: 10),
                            CustomTextField(
                              keyboardType: TextInputType.visiblePassword,
                              onChanged: (value) {
                                ref.read(pwProvider.notifier).state = value;
                              },
                              validationProvider: pwValidationProvider,
                              obscureText: true,
                              showPasswordToggle: true,
                              controller: _passwordController,
                              icon: Icons.lock,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Password';
                                }
                                return null;
                              },
                              hintText: 'Password',
                            ),
                            const SizedBox(
                              height: 35,
                            ),
                            Container(
                              width: 318,
                              height: 50,
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
                                onPressed: () => _login(),
                                child: Text('Login',
                                    style: TextStyle(
                                        fontSize: 24,
                                        color: secondaryLightColor)),
                              ),
                            ),
                            const SizedBox(height: 15),
                            InkWell(
                              onTap: () {
                                GoRouter.of(context)
                                    .go(Routes.resetpasswordScreen);
                              },
                              child: Text(
                                'Forgot password?',
                                style: TextStyle(
                                  color: primaryLightColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    color: primaryDarkColor
                                        .withAlpha((0.3 * 255).toInt()),
                                    thickness: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    'Or continue with',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: primaryDarkColor
                                        ..withAlpha((0.3 * 255).toInt()),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    color: primaryDarkColor
                                        .withAlpha((0.3 * 255).toInt()),
                                    thickness: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 88,
                              height: 45,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(19),
                                border: Border.all(
                                  color: primaryDarkColor
                                    ..withAlpha((0.3 * 255).toInt()),
                                ),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFFFFF),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(19),
                                  ),
                                ),
                                onPressed: () {},
                                child: CachedNetworkImage(
                                  imageUrl: 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEhShDVC1xlBkIwnEHfbrOFKXIvmJhjgmMw8Senh3cWgcgYYWfYuwAFmHaDYF7Alx6Ik-Wmy5PcYypyuE2ax1qHTXmirRtPZz3rcb7HJddz-tT6vfZ0zF5M1WCCmXGT1kL7GUmZaUZeqZPDzxRIn3JAwdhyphenhyphenMyGWzfItnh1sUicinLMNLW8pZyE1vXAJ5_L0X/s320/google_13170545.png',
                                  width: 47,
                                  height: 47,
                                  placeholder: (context, url) => Container(
                                    width: 47,
                                    height: 47,
                                    color: Colors.grey[200],
                                  ),
                                  errorWidget: (context, url, error) => const Icon(Icons.error, size: 47),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Don\'t have an account?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: primaryDarkColor
                                            .withAlpha((0.5 * 255).toInt()),
                                      )),
                                  InkWell(
                                    onTap: () {
                                      GoRouter.of(context).go(Routes.signUp);
                                    },
                                    child: Text(
                                      ' Register',
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
                      ),
                    ),
                  ],
                ),
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
        ),
      );
}
