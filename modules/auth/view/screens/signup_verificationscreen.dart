
/*
@Author - Anuruddha
@Date - 2025/03/29
 */
import 'package:adgo_mobile/modules/auth/data/apis/aws_cognito_api.dart';
import 'package:adgo_mobile/modules/auth/view/controllers/auth_controller.dart';
import 'package:adgo_mobile/services/providers/user_provider.dart';
import 'package:adgo_mobile/themes/utils.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:adgo_mobile/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key, required this.data});

  //final String username;
  final Map<String, String> data;

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  // Controllers for individual OTP digit fields
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  
  bool _isLoading = false;
  String? _obfuscatedEmail;

  @override
  void initState() {
    super.initState();
    _obfuscatedEmail = _obfuscateEmail(widget.data['username']!);
  }

  String _obfuscateEmail(String email) {
    if (email.contains('@')) {
      final parts = email.split('@');
      if (parts[0].length > 3) {
        return '${parts[0].substring(0, 3)}${'*' * (parts[0].length - 3)}@${parts[1]}';
      }
    }
    return email;
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
  
  String _getFullOtp() {
    return _otpControllers.map((controller) => controller.text).join();
  }
 
  Future<void> _verifyOtp() async {
    final otp = _getFullOtp();

    setState(() {
      _isLoading = true;
    });

    if (otp.isNotEmpty && otp.length == 6) {
      try {
        final isSuccess = await ref.read(confirmSignUpProvider((widget.data['username']!, otp)).future);

           
        if (isSuccess) {

          final userID = await ref.read(signUpAndGetUserIdProvider((widget.data['username']!,widget.data['password']!)).future);
          print("UsrID in verification");
          print(userID);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userID!);

          print("userid in verification screen");
          print(userID);

          final repo = ref.read(userRepoProvider);
          final response = await repo.saveUser(
            userId: userID,
            userName: "",
            email: widget.data['username']!,
            shopId: "",
            dob: DateTime.now(), // or any valid DateTime
            gender: "",
            profilePictureOBjectKey: "",
            state: true,
          );

          if(response.statusCode == 200) {
            // Set isLoggedIn ONLY after successful OTP verification AND backend user creation
            await prefs.setBool('isLoggedIn', true);
            await prefs.setString('username', widget.data['username']!);
            await prefs.remove('pendingVerificationEmail');
            
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User saved successfully")));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to save user")));
          }


          if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP confirmation successful")));
            GoRouter.of(context).go(Routes.home);
          }
        } else {
          if(mounted){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("OTP confirmation failed")),
            );
          }
        }
      } catch (error) {
        if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OTP confirmation failed: $error")));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Actually resend the OTP via Cognito
      final cognitoUser = CognitoUser(widget.data['username']!, CognitoUserPool(
        AwsCognitoApi.userPoolId,
        AwsCognitoApi.clientId,
      ));
      
      await cognitoUser.resendConfirmationCode();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP has been resent to your email')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to resend OTP: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _changeEmail() {
    // Go back to signup screen and clear pending verification
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('pendingVerificationEmail');
    });
    GoRouter.of(context).go(Routes.signUp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      'Enter Verification Code',
                      style: TextStyle(
                        color: primaryDarkColor,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enter Code We\'ve sent to your inbox',
                      style: TextStyle(
                        color: primaryDarkColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _obfuscatedEmail ?? widget.data['username']!,
                      style: TextStyle(
                        color: primaryDarkColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Change Email Button
                    TextButton(
                      onPressed: _changeEmail,
                      child: Text(
                        'Wrong email? Change it',
                        style: TextStyle(
                          color: primaryLightColor,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (index) => _buildOtpDigitField(index),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Didn't receive OTP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Didn\'t receive the OTP? ',
                          style: TextStyle(
                            color: primaryDarkColor,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: _resendOtp,
                          child: Text(
                            'Resend OTP',
                            style: TextStyle(
                              color: primaryLightColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Proceed Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryLightColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _verifyOtp,
                        child: Text(
                          'Proceed',
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: primaryDarkColor.withAlpha((0.3 * 255).toInt()),
              child: Center(
                child: CircularProgressIndicator(
                  color: primaryLightColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOtpDigitField(int index) {
    return Container(
      width: 45,
      height: 50,
      decoration: BoxDecoration(
        color: _otpControllers[index].text.isNotEmpty 
            ? primaryLightColor 
            : primaryLightColor.withAlpha((0.3 * 255).toInt()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        onChanged: (value) {
          if (value.length == 1) {
            // Move to next field
            if (index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else {
              _focusNodes[index].unfocus();
              // Auto verify when all digits are entered
              if (_getFullOtp().length == 6) {
                _verifyOtp();
              }
            }
          }
        },
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: _otpControllers[index].text.isNotEmpty 
              ? whiteColor 
              : primaryDarkColor,
        ),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: "",
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    );
  }
}