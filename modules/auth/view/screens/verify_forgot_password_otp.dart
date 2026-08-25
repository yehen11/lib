// ignore_for_file: library_private_types_in_public_api

/*
@Author - Anuruddha
@Date - 2025/03/29
 */
import 'package:adgo_mobile/themes/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:adgo_mobile/routes/routes.dart';

class OtpVerificationForgotPWScreen extends ConsumerStatefulWidget {
  const OtpVerificationForgotPWScreen({super.key, required this.username});

  final String username;

  @override
  _OtpVerificationForgotPWScreenState createState() => _OtpVerificationForgotPWScreenState();
}

class _OtpVerificationForgotPWScreenState extends ConsumerState<OtpVerificationForgotPWScreen> {
  // Controllers for individual OTP digit fields
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );

  String? _obfuscatedEmail;

  @override
  void initState() {
    super.initState();
    _obfuscatedEmail = _obfuscateEmail(widget.username);
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
    String otp = _getFullOtp();

    if (otp.length == 6) {
      if (mounted) {
        GoRouter.of(context).push(
          Routes.newPasswordScreen,
          extra: {'otp': otp, 'username': widget.username},
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
    }
  }

  void _resendOtp() {
    // Implementation for resending OTP would go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP Resent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                // Illustration
                Image.network(
                  'https://adgo-logo-public.s3.ap-south-1.amazonaws.com/images/otp.png',
                  height: 243,
                  width: 243,
                ),
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
                    color: primaryDarkColor.withAlpha((0.6 * 255).toInt()),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _obfuscatedEmail ?? widget.username,
                  style: TextStyle(
                    color: primaryLightColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
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
                        color: primaryDarkColor.withAlpha((0.6 * 255).toInt()),
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
