import 'package:adgo_mobile/modules/shop/view/controllers/shop_provider.dart';
import 'package:adgo_mobile/modules/shop/view/screens/preview_screen.dart';
import 'package:adgo_mobile/themes/Utils.dart';
import 'package:adgo_mobile/validation/providers/fb_validation_provider.dart';
import 'package:adgo_mobile/validation/providers/insta_validation_provider.dart';
import 'package:adgo_mobile/validation/providers/tt_validation_provider.dart';
import 'package:adgo_mobile/validation/providers/x_validation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adgo_mobile/widgets/customTextField.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SocialMediaScreen extends ConsumerStatefulWidget {
  const SocialMediaScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SocialMediaScreen> createState() => _SocialMediaScreenState();
}

class _SocialMediaScreenState extends ConsumerState<SocialMediaScreen> {
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _twitterController = TextEditingController();
  final _tiktokController = TextEditingController();
  bool _isLoading = false;

  bool get isEditMode {
    final form = ref.read(shopFormProvider);
    return form.shopId != null && form.shopId!.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    // Load any existing data from the provider when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingData();
    });
  }

  void save() async {
    if (!_validateFields()) {
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });

      final shopForm = ref.read(shopFormProvider.notifier);
      shopForm.updateInstaLink(_instagramController.text);
      shopForm.updateFBLink(_facebookController.text);
      shopForm.updateTWLink(_twitterController.text);

      // Save TikTok to SharedPreferences (not in main form model)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('draft_tiktok', _tiktokController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ReviewPublishScreen(),
          ),
        );
      }
    } catch (e) {
      print("Error saving social media info: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
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

  void _loadExistingData() {
    final shopForm = ref.read(shopFormProvider);

    // Load existing social media data into text controllers AND update validators
    if (shopForm.instagram != null && shopForm.instagram!.isNotEmpty) {
      _instagramController.text = shopForm.instagram!;
      // Update the state provider so validation works
      ref.read(instaProvider.notifier).state = shopForm.instagram!;
    }
    if (shopForm.facebook != null && shopForm.facebook!.isNotEmpty) {
      _facebookController.text = shopForm.facebook!;
      // Update the state provider so validation works
      ref.read(fbProvider.notifier).state = shopForm.facebook!;
    }
    if (shopForm.twitter != null && shopForm.twitter!.isNotEmpty) {
      _twitterController.text = shopForm.twitter!;
      // Update the state provider so validation works
      ref.read(xProvider.notifier).state = shopForm.twitter!;
    }

    // Load TikTok from shared preferences (since it's not in shop form model)
    _loadDraftTikTok();
  }

  Future<void> _loadDraftTikTok() async {
    final prefs = await SharedPreferences.getInstance();
    final tiktok = prefs.getString('draft_tiktok') ?? '';
    if (tiktok.isNotEmpty) {
      _tiktokController.text = tiktok;
      ref.read(ttProvider.notifier).state = tiktok;
    }
  }

  @override
  void dispose() {
    _instagramController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
    _tiktokController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    final instagramValidation = ref.read(instaValidationProvider);
    final facebookValidation = ref.read(fbValidationProvider);
    final twitterValidation = ref.read(xValidationProvider);
    final tiktokValidation = ref.read(ttValidationProvider);

    if (!instagramValidation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(instagramValidation.error ?? 'Invalid Instagram username or URL')),
      );
      return false;
    }

    if (!facebookValidation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(facebookValidation.error ?? 'Invalid Facebook username or URL')),
      );
      return false;
    }

    if (!twitterValidation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(twitterValidation.error ?? 'Invalid Twitter/X username or URL')),
      );
      return false;
    }

    if (!tiktokValidation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(tiktokValidation.error ?? 'Invalid TikTok username or URL')),
      );
      return false;
    }

    return true;
  }

  Future<void> _saveSocialDraft() async {
    final prefs = await SharedPreferences.getInstance();

    // Save TikTok to SharedPreferences (since it's not in shop form model)
    await prefs.setString('draft_tiktok', _tiktokController.text);
  }

  void _processNextStep() async {
    if (!_validateFields()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Social media information saved successfully')),
        );

        final shopForm = ref.read(shopFormProvider.notifier);
        shopForm.updateFBLink(_facebookController.text);
        shopForm.updateInstaLink(_instagramController.text);
        shopForm.updateTWLink(_twitterController.text);
        
        // Save TikTok draft before navigating
        await _saveSocialDraft();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReviewPublishScreen(),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryDarkColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Social Media',
          style: TextStyle(
            color: primaryDarkColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Instagram',
                              style: TextStyle(fontSize: 14, color: primaryDarkColor)),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _instagramController,
                            onChanged: (value) {
                              ref.read(instaProvider.notifier).state = value;
                            },
                            validationProvider: instaValidationProvider,
                            icon: Icons.link,
                            validator: (value) {
                              return null;
                            },
                            hintText: 'Enter Instagram username or URL',
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 24),
                          
                          Text('Facebook',
                              style: TextStyle(fontSize: 14, color: primaryDarkColor)),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _facebookController,
                            onChanged: (value) {
                              ref.read(fbProvider.notifier).state = value;
                            },
                            validationProvider: fbValidationProvider,
                            icon: Icons.link,
                            validator: (value) {
                              return null;
                            },
                            hintText: 'Enter Facebook username or URL',
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 24),
                          
                          Text('Twitter/X',
                              style: TextStyle(fontSize: 14, color: primaryDarkColor)),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _twitterController,
                            onChanged: (value) {
                              ref.read(xProvider.notifier).state = value;
                            },
                            validationProvider: xValidationProvider,
                            icon: Icons.link,
                            validator: (value) {
                              return null;
                            },
                            hintText: 'Enter Twitter/X username or URL',
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 24),
                          
                          Text('TikTok',
                              style: TextStyle(fontSize: 14, color: primaryDarkColor)),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _tiktokController,
                            onChanged: (value) {
                              ref.read(ttProvider.notifier).state = value;
                            },
                            validationProvider: ttValidationProvider,
                            icon: Icons.link,
                            validator: (value) {
                              return null;
                            },
                            hintText: 'Enter TikTok username or URL',
                            keyboardType: TextInputType.text,
                          ),
                          const SizedBox(height: 24),
                          
                          Center(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ReviewPublishScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'Skip this step',
                                style: TextStyle(
                                  color: primaryLightColor,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 14),
                  
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 4 / 6,
                      backgroundColor: primaryDarkColor.withAlpha((0.1 * 255).toInt()),
                      valueColor: AlwaysStoppedAnimation<Color>(primaryLightColor),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Step 4 of 6',
                      style: TextStyle(
                        color: primaryDarkColor.withAlpha((0.3 * 255).toInt()),
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  
                  isEditMode
                      ? SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : save,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: primaryLightColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: Text(
                              'Save',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: whiteColor,
                                  side: BorderSide(
                                      color: primaryDarkColor
                                          .withAlpha((0.3 * 255).toInt())),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Back',
                                  style: TextStyle(
                                      color: primaryDarkColor, fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _processNextStep,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: primaryLightColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Next',
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
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
}