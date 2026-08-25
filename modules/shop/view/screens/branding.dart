import 'dart:io';

import 'package:adgo_mobile/modules/shop/view/controllers/shop_provider.dart';
import 'package:adgo_mobile/modules/shop/view/screens/contact_info.dart';
import 'package:adgo_mobile/modules/shop/view/screens/preview_screen.dart';
import 'package:adgo_mobile/services/providers/shop_provider.dart';
import 'package:adgo_mobile/themes/Utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ShopBrandingScreen extends ConsumerStatefulWidget {
  const ShopBrandingScreen({Key? key}) : super(key: key);

  @override
  _ShopBrandingScreenState createState() => _ShopBrandingScreenState();
}

class _ShopBrandingScreenState extends ConsumerState<ShopBrandingScreen> {
  File? _logoImage;
  File? _bannerImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  bool get isEditMode {
    final form = ref.read(shopFormProvider);
    return form.shopId != null && form.shopId!.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    // Load any existing images from the provider when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingImages();
    });
  }

  void save() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Upload images if they were changed (optional in edit mode)
      if (_logoImage != null || _bannerImage != null) {
        await _uploadImages(requireBoth: false);
      }

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
      print("Error saving branding: $e");
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

  void _loadExistingImages() {
    final shopForm = ref.read(shopFormProvider);

    // Load existing images from the provider
    if (shopForm.logoImage != null) {
      setState(() {
        _logoImage = shopForm.logoImage;
      });
    }

    if (shopForm.bannerImage != null) {
      setState(() {
        _bannerImage = shopForm.bannerImage;
      });
    }

    // Show success message if any images were loaded
    if (shopForm.logoImage != null || shopForm.bannerImage != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Draft images loaded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Method to validate aspect ratio
  Future<bool> _validateAspectRatio(File imageFile, bool isLogo) async {
    try {
      final decodedImage = await decodeImageFromList(await imageFile.readAsBytes());
      final width = decodedImage.width.toDouble();
      final height = decodedImage.height.toDouble();
      final aspectRatio = width / height;

      if (isLogo) {
        // Logo should be approximately 1:1 (tolerance: 0.8 to 1.2)
        return aspectRatio >= 0.8 && aspectRatio <= 1.2;
      } else {
        // Banner should be approximately 16:9 ≈ 1.78 (tolerance: 1.6 to 2.0)
        return aspectRatio >= 1.6 && aspectRatio <= 2.0;
      }
    } catch (e) {
      debugPrint('Error validating aspect ratio: $e');
      return false;
    }
  }

  // Method to show aspect ratio error dialog
  void _showAspectRatioError(bool isLogo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Invalid ${isLogo ? 'Logo' : 'Banner'} Aspect Ratio',
            style: TextStyle(color: primaryDarkColor),
          ),
          content: Text(
            isLogo
                ? 'Please select a logo image with approximately 1:1 aspect ratio (square image).'
                : 'Please select a banner image with approximately 16:9 aspect ratio (wide rectangular image).',
            style: TextStyle(color: primaryDarkColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'OK',
                style: TextStyle(color: primaryLightColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickLogo() async {
    final pickedFile = await await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800, // prevent full-resolution image
      maxHeight: 800,
      imageQuality: 85, // compress JPEG
    );
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      
      // Validate aspect ratio immediately after selection
      final isValidRatio = await _validateAspectRatio(imageFile, true);
      
      if (isValidRatio) {
        setState(() {
          _logoImage = imageFile;
        });
      } else {
        // Show error dialog and clear selection
        _showAspectRatioError(true);
        setState(() {
          _logoImage = null;
        });
      }
    }
  }

  Future<void> _pickBanner() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      
      // Validate aspect ratio immediately after selection
      final isValidRatio = await _validateAspectRatio(imageFile, false);
      
      if (isValidRatio) {
        setState(() {
          _bannerImage = imageFile;
        });
      } else {
        // Show error dialog and clear selection
        _showAspectRatioError(false);
        setState(() {
          _bannerImage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: whiteColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryDarkColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Shop Branding',
            style: TextStyle(
              color: primaryDarkColor,
            )),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text('Logo',
                    style: TextStyle(fontSize: 24, color: primaryDarkColor)),
                Text('Add your shop logo',
                    style: TextStyle(
                        fontSize: 14,
                        color:
                            primaryDarkColor.withAlpha((0.3 * 255).toInt()))),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickLogo,
                  child: Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 90,
                      backgroundColor:
                          primaryLightColor.withAlpha((0.1 * 255).toInt()),
                      child: _logoImage != null
                          ? ClipOval(
                              child: Image.file(
                                _logoImage!,
                                width: 160,
                                height: 160,
                                fit: BoxFit.cover,
                                cacheWidth: 320,
                                cacheHeight: 320,
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(28.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: primaryLightColor
                                        .withAlpha((0.3 * 255).toInt()),
                                    radius: 24,
                                    child: Icon(
                                        Icons.add_photo_alternate_outlined,
                                        color: primaryLightColor),
                                  ),
                                  const SizedBox(height: 12),
                                  Text('Upload Logo',
                                      style:
                                          TextStyle(color: primaryDarkColor)),
                                  Text('Recommended',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: primaryDarkColor
                                          .withAlpha((0.3 * 255).toInt()))),
                                          Text('aspect ratio: 1:1',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: primaryDarkColor
                                          .withAlpha((0.3 * 255).toInt()))),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text('Banner',
                    style: TextStyle(fontSize: 24, color: primaryDarkColor)),
                Text('Add a banner for your shop page',
                    style: TextStyle(
                        fontSize: 14,
                        color:
                            primaryDarkColor.withAlpha((0.3 * 255).toInt()))),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickBanner,
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: primaryLightColor.withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color:
                              primaryDarkColor.withAlpha((0.1 * 255).toInt())),
                    ),
                    child: _bannerImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _bannerImage!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              cacheWidth:
                                  MediaQuery.of(context).size.width.toInt() * 2,
                              cacheHeight: 240,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: primaryLightColor
                                    .withAlpha((0.1 * 255).toInt()),
                                radius: 24,
                                child: Icon(Icons.panorama_outlined,
                                    color: primaryLightColor),
                              ),
                              const SizedBox(height: 8),
                              Text('Upload Banner',
                                  style: TextStyle(color: primaryDarkColor)),
                              Text('Recommended aspect ratio: 16/9',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: primaryDarkColor
                                          .withAlpha((0.3 * 255).toInt()))),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 40),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 2 / 6,
                    backgroundColor:
                        primaryDarkColor.withAlpha((0.1 * 255).toInt()),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(primaryLightColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: Text('Step 2 of 6',
                      style: TextStyle(
                          fontSize: 14,
                          color:
                              primaryDarkColor.withAlpha((0.3 * 255).toInt()))),
                ),
                const SizedBox(height: 24),
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
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        setState(() {
                                          _isLoading = true;
                                        });

                                        try {
                                          await _uploadImages(
                                              requireBoth: true);

                                          if (mounted) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const ContactInformationScreen(),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(content: Text("$e")),
                                            );
                                          }
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          }
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: primaryLightColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: Text(
                                  'Upload',
                                  style: TextStyle(
                                    color: whiteColor,
                                    fontSize: 16,
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

  Future<void> _uploadImages({bool requireBoth = false}) async {
    final shopForm = ref.read(shopFormProvider.notifier);
    final shopRepo = ref.read(shopRepoProvider);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      throw Exception("UserID is null");
    }

    // Validate images if required
    if (requireBoth) {
      if (_logoImage == null) {
        throw Exception("Please select a shop logo");
      }
      if (_bannerImage == null) {
        throw Exception("Please select a shop banner");
      }
    }

    // Upload logo if selected
    if (_logoImage != null) {
      final logoName = _logoImage!.path.split('/').last;
      final uploadLogoResponse = await shopRepo.getShopLogoUploadUrl(
        userId: userId,
        logoName: logoName,
      );
      final uploadUrl = uploadLogoResponse.data['uploadUrl'];
      final logoKey = uploadLogoResponse.data['key'];

      List<int> fileBytes = await _logoImage!.readAsBytes();
      var request = http.Request('PUT', Uri.parse(uploadUrl));
      String contentTypeString = _logoImage!.path.endsWith('.png') ||
              _logoImage!.path.endsWith('.jpg') ||
              _logoImage!.path.endsWith('.jpeg')
          ? 'image'
          : 'video';

      request.headers['Content-Type'] = contentTypeString;
      request.bodyBytes = fileBytes;

      var response = await request.send();
      if (response.statusCode == 200) {
        print('Logo uploaded successfully');
        shopForm.updateLogoUrl(logoKey);
        shopForm.updateLogoImage(_logoImage);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Logo uploaded successfully")),
          );
        }
      } else {
        throw Exception('Failed to upload the logo. try again!');
      }
    }

    // Upload banner if selected
    if (_bannerImage != null) {
      final bannerName = _bannerImage!.path.split('/').last;
      final uploadBannerResponse = await shopRepo.getShopBannerUploadUrl(
        userId: userId,
        bannerName: bannerName,
      );
      final uploadUrl = uploadBannerResponse.data['uploadUrl'];
      final bannerKey = uploadBannerResponse.data['key'];

      List<int> fileBytes = await _bannerImage!.readAsBytes();
      var request = http.Request('PUT', Uri.parse(uploadUrl));
      String contentTypeString = _bannerImage!.path.endsWith('.png') ||
              _bannerImage!.path.endsWith('.jpg') ||
              _bannerImage!.path.endsWith('.jpeg')
          ? 'image'
          : 'video';

      request.headers['Content-Type'] = contentTypeString;
      request.bodyBytes = fileBytes;

      var response = await request.send();
      if (response.statusCode == 200) {
        print('Banner uploaded successfully');
        shopForm.updateBannerUrl(bannerKey);
        shopForm.updateBannerImage(_bannerImage);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Banner uploaded successfully")),
          );
        }
      } else {
        throw Exception('Failed to upload the banner. try again!');
      }
    }
  }
}
