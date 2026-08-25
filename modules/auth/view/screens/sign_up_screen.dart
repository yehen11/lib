/*
@Author - Anuruddha
@Date - 2025/02/11
 */
import 'dart:convert';
import 'package:adgo_mobile/modules/auth/view/controllers/auth_controller.dart';
import 'package:adgo_mobile/routes/routes.dart';
import 'package:adgo_mobile/themes/utils.dart';
import 'package:adgo_mobile/widgets/customTextField.dart';
import 'package:amazon_cognito_identity_dart_2/sig_v4.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:adgo_mobile/validation/providers/email_validation_provider.dart';
import 'package:adgo_mobile/validation/providers/password_validation_provider.dart';



class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}


class Policy {
  String expiration;
  String region;
  String bucket;
  String key;
  String credential;
  String datetime;
  int maxFileSize;

  Policy(this.key, this.bucket, this.datetime, this.expiration, this.credential,
      this.maxFileSize,
      {this.region = 'us-east-1'});

  factory Policy.fromS3PresignedPost(
    String key,
    String bucket,
    String accessKeyId,
    int expiryMinutes,
    int maxFileSize, {
    required String region,
  }) {
    final datetime = SigV4.generateDatetime();
    final expiration = (DateTime.now())
        .add(Duration(minutes: expiryMinutes))
        .toUtc()
        .toString()
        .split(' ')
        .join('T');
    final cred =
        '$accessKeyId/${SigV4.buildCredentialScope(datetime, region, 's3')}';
    final p = Policy(key, bucket, datetime, expiration, cred, maxFileSize,
        region: region);
    return p;
  }

  String encode() {
    final bytes = utf8.encode(toString());
    return base64.encode(bytes);
  }

  @override
  String toString() {
    return '''
{ "expiration": "$expiration",
  "conditions": [
    {"bucket": "$bucket"},
    ["starts-with", "\$key", "$key"],
    {"acl": "public-read"},
    ["content-length-range", 1, $maxFileSize],
    {"x-amz-credential": "$credential"},
    {"x-amz-algorithm": "AWS4-HMAC-SHA256"},
    {"x-amz-date": "$datetime" }
  ]
}
''';
  }
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController = TextEditingController();

  bool _isLoading = false;

  @override
void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
  _passwordConfirmController.dispose();
  super.dispose();
}


void _signUpUser() async {
  setState(() {
        _isLoading = true;
      });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _passwordConfirmController.text.trim();

    final emailValidation = ref.read(emailValidationProvider);
    final passwordValidation = ref.read(pwValidationProvider);
    
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    
    if (!emailValidation.isValid) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailValidation.error ?? 'Invalid email format')),
      );
      return;
    }

    if (!passwordValidation.isValid) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passwordValidation.error ?? 'Invalid password format')),
      );
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }


    try {
      final isSuccess = await ref.read(signUpUserProvider((email, password, context)).future);
      if (isSuccess) {
       if(mounted){
          GoRouter.of(context).go(Routes.verificationScreen, extra: {'password': _passwordConfirmController.text, 'username': _emailController.text});
        }
       
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sign up failed")),
        );
      }
    } catch (error) {
      if(mounted){
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sign up failed: $error")));
          return;
        }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
      /*ref.read(signUpUserProvider((_emailController.text, _passwordConfirmController.text, context)).future)
      .then((_) {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sign up successful")));
          GoRouter.of(context).go(Routes.verificationScreen,extra: _emailController.text);
        }
        
      })
      .catchError((error) {
        if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sign up failed: \$error")));
        }
      });*/
  }



  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
        body: Stack(
          children: [
            Padding(
            padding: const EdgeInsets.fromLTRB(35, 0, 36, 5),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                  CachedNetworkImage(
                    imageUrl: 'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjPN0qeCqXVzUNNr6EuXsmUWU_9UAvBZvCfRt6NnkbH6dllXaQv38lSzvmNCGG6ocv4sSD4s6ovQj09X4K4n_mHsiFAQzkyZNbNiuZLg0DOQkK-KvZhGNMLqp100OfVpqPn9v5WRZ57nwUyxhxq7MTIxbHBwnjZgqGx_miyPaMlahyphenhypheni_ghoMhKX8ExtdZ2b/s320/Personal_rafiki.png',
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
                  'Register to Your Account',
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
                  onChanged: (value) {
                      ref.read(emailProvider.notifier).state = value;
                    },
                  validationProvider: emailValidationProvider,
                  keyboardType: TextInputType.visiblePassword,
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
                    height: 10,
                ),
                CustomTextField(
                  obscureText: true,
                  showPasswordToggle: true,
                  controller: _passwordConfirmController,
                  icon: Icons.lock,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your Password';
                    }
                    return null;
                  },
                  hintText: 'Confirm Password',
                ),
                const SizedBox(
                    height: 25,
                ),
                Container(
                  width: 318,
                    height: 58,
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
                    onPressed: () async{
                       _signUpUser();
                    }, //_login,
                      child: Text('Register',
                        style:
                            TextStyle(fontSize: 24, color: whiteColor)),
                  ),
                ),
                  const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: primaryDarkColor.withAlpha((0.3 * 255).toInt()),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryDarkColor.withAlpha((0.3 * 255).toInt()),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: primaryDarkColor.withAlpha((0.3 * 255).toInt()),
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                    height: 15,
                ),
                Container(
                  width: 88,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(19),
                    border:
                        Border.all(
                          color:
                              primaryDarkColor.withAlpha((0.3 * 255).toInt())),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: whiteColor,
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
                    height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?',
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryDarkColor.withAlpha((0.5 * 255).toInt()),
                        )),
                    InkWell(
                      onTap: () {
                        GoRouter.of(context).go(Routes.login);
                      },
                      child: Text(
                        ' Sign in',
                        style: TextStyle(
                          color: primaryLightColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_isLoading)
              const LinearProgressIndicator(),
          ],
        )
      );
}
