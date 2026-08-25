import 'package:adgo_mobile/modules/auth/view/controllers/auth_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:adgo_mobile/routes/routes.dart';
import 'package:adgo_mobile/themes/utils.dart';

class SendVerificationCodeScreen extends ConsumerStatefulWidget {
  const SendVerificationCodeScreen({super.key, required this.username});

  final String username;

  @override
  // ignore: library_private_types_in_public_api
  _SendVerificationCodeScreenState createState() =>
      _SendVerificationCodeScreenState();
}

class _SendVerificationCodeScreenState
    extends ConsumerState<SendVerificationCodeScreen> {
  bool _isLoading = false;

  Future<void> _sendVerificationCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final isSuccess = await ref.read(forgotPasswordProvider(widget.username).future);
      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification code sent")),
        );
        GoRouter.of(context).push(
          Routes.otpVerificationForgotPWScreen,
          extra: widget.username,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send verification code")),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sending failed: $error")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Send Verification Code')),
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
                            imageUrl: 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjUOpbfB32DmjoIG0CeSheYkuI5s81oNSupJpOHxnqvHCEzLfSPRxt8Dm-incOOS7FveGFUnzcgUySAa_ZHozco8EcbD8edbMtTtcVJ1H3lEJ1kwxzXkjGv9jxP1KcIUU5c99eoqHi_wuov5hTGBtw15neovU7LBCM_bh-UqF28cbDcieal1f6V7kd2Q9VX/s320/Mail_sent_rafiki.png',
                            width: 243,
                            height: 243,
                            placeholder: (context, url) => Container(
                              width: 243,
                              height: 243,
                              color: Colors.grey[200],
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error, size: 100),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Send verification Code to',
                                style: TextStyle(
                                  color: primaryDarkColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.username,
                                style: TextStyle(
                                  color: primaryLightColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Send one time passcode to your emaill address to reset your password ',
                                style: TextStyle(
                                  color: primaryDarkColor
                                      .withAlpha((0.3 * 255).toInt()),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const SizedBox(height: 45),
                          
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
                    onPressed:
                        _isLoading ? null : () => _sendVerificationCode(),
                    child: Text('Send Code',
                        style: TextStyle(
                            fontSize: 24, color: secondaryLightColor)),
                  ),
                ),
                        ],
                      ),
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