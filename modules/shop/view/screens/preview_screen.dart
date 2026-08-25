import 'dart:io';
import 'package:adgo_mobile/modules/shop/view/controllers/shop_provider.dart';
import 'package:adgo_mobile/modules/shop/view/screens/basic_info.dart';
import 'package:adgo_mobile/modules/shop/view/screens/branding.dart';
import 'package:adgo_mobile/modules/shop/view/screens/contact_info.dart';
import 'package:adgo_mobile/modules/shop/view/screens/shoplive.dart';
import 'package:adgo_mobile/modules/shop/view/screens/social.dart';
import 'package:adgo_mobile/modules/shop/view/screens/welcome_screen.dart';
import 'package:adgo_mobile/services/providers/shop_provider.dart';
import 'package:adgo_mobile/services/repositories/shop_repository.dart';
import 'package:adgo_mobile/themes/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewPublishScreen extends ConsumerStatefulWidget {
  const ReviewPublishScreen({Key? key}) : super(key: key);

  @override
  _ReviewPublishScreenState createState() => _ReviewPublishScreenState();
}

class _ReviewPublishScreenState extends ConsumerState<ReviewPublishScreen> {
  bool _isLoading = false;
  bool _isDraftSaving = false; // Add this for draft loading state
  String? _bannerDownloadUrl;
  String? _logoDownloadUrl;
  final ShopRepository _shopRepository = ShopRepository();

  // Check if we're in edit mode (updating existing shop)
  bool get isEditMode {
    final form = ref.read(shopFormProvider);
    return form.shopId != null && form.shopId!.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _loadShopImages();
  }

  Future<void> _loadShopImages() async {
    final form = ref.read(shopFormProvider);

    // Only fetch download URLs if we're in edit mode and have URL keys
    if (!isEditMode) return;

    try {
      // Fetch banner download URL
      if (form.bannerUrl != null && form.bannerUrl!.isNotEmpty) {
        try {
          final bannerResponse = await _shopRepository.getShopBannerDownloadUrl(
            bannerKey: form.bannerUrl!,
          );

          if (bannerResponse.statusCode == 200 && mounted) {
            final responseData = bannerResponse.data;
            final downloadUrl = responseData is String
                ? responseData
                : responseData['downloadUrl']?.toString() ??
                    responseData['url']?.toString();

            if (downloadUrl != null) {
              setState(() {
                _bannerDownloadUrl = downloadUrl;
              });
            }
          }
        } catch (e) {
          debugPrint('Failed to load banner image: $e');
        }
      }

      // Fetch logo download URL
      if (form.logoUrl != null && form.logoUrl!.isNotEmpty) {
        try {
          final logoResponse = await _shopRepository.getShopLogoDownloadUrl(
            logoKey: form.logoUrl!,
          );

          if (logoResponse.statusCode == 200 && mounted) {
            final responseData = logoResponse.data;
            final downloadUrl = responseData is String
                ? responseData
                : responseData['downloadUrl']?.toString() ??
                    responseData['url']?.toString();

            if (downloadUrl != null) {
              setState(() {
                _logoDownloadUrl = downloadUrl;
              });
            }
          }
        } catch (e) {
          debugPrint('Failed to load logo image: $e');
        }
      }
    } catch (e) {
      debugPrint('Failed to load shop images: $e');
    }
  }

  // Add this method for saving draft
  Future<void> _saveAsDraft() async {
    setState(() {
      _isDraftSaving = true;
    });

    try {
      // Step 1: Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Step 2: Get form data from memory
      final form = ref.read(shopFormProvider);

      // Step 3: Create pipe-separated string with all form data
      final draftData = [
        form.name ?? '',
        form.handle ?? '',
        form.description ?? '',
        form.category ?? '',
        form.email ?? '',
        form.phone ?? '',
        form.instagram ?? '',
        form.facebook ?? '',
        form.twitter ?? '',
        form.logoImage?.path ?? '',
        form.bannerImage?.path ?? '',
      ].join('|||');

      // Step 4: Save the draft data
      await prefs.setString('shop_draft', draftData);

      // Step 4.1: Save TikTok separately (since it's not in the main form model)
      final tiktok = prefs.getString('draft_tiktok') ?? '';
      if (tiktok.isNotEmpty) {
        await prefs.setString('draft_tiktok', tiktok);
      }

      // Step 5: Save additional contact info that's not in the main form model
      // These are stored separately because they're not part of shopFormProvider
      final addressLine1 = prefs.getString('temp_address_line1') ?? '';
      final addressLine2 = prefs.getString('temp_address_line2') ?? '';
      final addressLine3 = prefs.getString('temp_address_line3') ?? '';
      final businessHours = prefs.getString('temp_business_hours') ?? '';

      if (addressLine1.isNotEmpty ||
          addressLine2.isNotEmpty ||
          addressLine3.isNotEmpty) {
        await prefs.setString('draft_address_line1', addressLine1);
        await prefs.setString('draft_address_line2', addressLine2);
        await prefs.setString('draft_address_line3', addressLine3);
      }

      if (businessHours.isNotEmpty) {
        await prefs.setString('draft_business_hours', businessHours);
      }

      // Step 6: Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Draft saved successfully!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'You can continue editing or publish when ready.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }

      // Note: No navigation - user stays on preview screen after saving draft
    } catch (e) {
      // Step 7: Handle errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to save draft: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Step 8: Reset loading state
      if (mounted) {
        setState(() {
          _isDraftSaving = false;
        });
      }
    }
  }

  Future<void> createShop() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      print("userID in shop creating ========");
      print(userId);
      if (userId == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("UserID is null")));
        return;
      }

      final repo = ref.read(shopRepoProvider);
      final form = ref.read(shopFormProvider);

      Map<String, String>? socialMediaLinks = {
        "facebook": form.facebook!,
        "instagram": form.instagram!,
        "twitter": form.twitter!,
      };

      // Null or empty check
      if ([form.name, form.handle, userId, form.description, form.category, form.email, form.phone]
              .any((element) => element == null || (element is String && element.isEmpty)) ||
          form.bannerImage == null ||
          form.logoImage == null ||
          socialMediaLinks == null ||
          socialMediaLinks.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await repo.setShop(
          name: form.name!,
          handle: form.handle!,
          ownerId: userId,
          bannerUrl: form.bannerUrl!,
          logoUrl: form.logoUrl!,
          description: form.description!,
          category: form.category!,
          email: form.email!,
          phoneNumber: form.phone!,
          socialMediaLinks: {
            "facebook": form.facebook!,
            "instagram": form.instagram!,
            "twitter": form.twitter!,
            // TikTok excluded - backend doesn't support it yet (draft-only feature)
          },
          active: true);

      print("✅ Shop created: ${response.data}");

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        //await prefs.setBool('isShopCreated', true);
        
        // Clean up draft after successful publish
        await prefs.remove('shop_draft');
        await prefs.remove('draft_tiktok');
        await prefs.remove('draft_address_line1');
        await prefs.remove('draft_address_line2');
        await prefs.remove('draft_address_line3');
        await prefs.remove('draft_business_hours');
        await prefs.remove('draft_selected_days');
        await prefs.remove('draft_open_time_minutes');
        await prefs.remove('draft_close_time_minutes');
        await prefs.remove('temp_address_line1');
        await prefs.remove('temp_address_line2');
        await prefs.remove('temp_address_line3');
        await prefs.remove('temp_business_hours');
        
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Shop created successfully")));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShopLiveScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Failed to save shop")));
      }
    } catch (e) {
      print("Failed to create shop: $e");
    } finally {
      setState(() {
        _isLoading = false; // Fixed: was setting to true
      });
    }
  }

  Future<void> updateShop() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      print("userID in shop updating ========");
      print(userId);
      if (userId == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("UserID is null")));
        return;
      }

      final repo = ref.read(shopRepoProvider);
      final form = ref.read(shopFormProvider);

      Map<String, String>? socialMediaLinks = {
        "facebook": form.facebook!,
        "instagram": form.instagram!,
        "twitter": form.twitter!,
      };

      // Null or empty check - for update, check URLs instead of images
      if ([
            form.name,
            form.handle,
            userId,
            form.description,
            form.category,
            form.email,
            form.phone
          ].any((element) =>
              element == null || (element is String && element.isEmpty)) ||
          form.bannerUrl == null ||
          form.bannerUrl!.isEmpty ||
          form.logoUrl == null ||
          form.logoUrl!.isEmpty ||
          socialMediaLinks == null ||
          socialMediaLinks.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Please fill in all required fields")));
        return;
      }

      final response = await repo.updateShop(
          shopId: form.shopId!,
          name: form.name!,
          handle: form.handle!,
          ownerId: userId,
          bannerUrl: form.bannerUrl!,
          logoUrl: form.logoUrl!,
          description: form.description!,
          category: form.category!,
          email: form.email!,
          phoneNumber: form.phone!,
          socialMediaLinks: {
            "facebook": form.facebook!,
            "instagram": form.instagram!,
            "twitter": form.twitter!,
            // TikTok excluded - backend doesn't support it yet (draft-only feature)
          },
          active: true);

      print("✅ Shop updated: ${response.data}");

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        //await prefs.setBool('isShopCreated', true);

        // Clean up draft after successful publish
        await prefs.remove('shop_draft');
        await prefs.remove('draft_tiktok');
        await prefs.remove('draft_address_line1');
        await prefs.remove('draft_address_line2');
        await prefs.remove('draft_address_line3');
        await prefs.remove('draft_business_hours');
        await prefs.remove('draft_selected_days');
        await prefs.remove('draft_open_time_minutes');
        await prefs.remove('draft_close_time_minutes');
        await prefs.remove('temp_address_line1');
        await prefs.remove('temp_address_line2');
        await prefs.remove('temp_address_line3');
        await prefs.remove('temp_business_hours');

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Shop updated successfully")));

        // Pop all screens until we reach WelcomeScreen
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to update shop")));
      }
    } catch (e) {
      print("Failed to update shop: $e");
    } finally {
      setState(() {
        _isLoading = false; // Fixed: was setting to true
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(shopFormProvider);
    
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: whiteColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryDarkColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Review & Publish',
          style: TextStyle(
            color: primaryDarkColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Shop Preview Section with actual data
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: primaryDarkColor.withAlpha((0.3 * 255).toInt())),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Image
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: Container(
                          width: double.infinity,
                          height: 120,
                          decoration: BoxDecoration(
                            color: primaryDarkColor.withAlpha((0.1 * 255).toInt()),
                          ),
                          child: _bannerDownloadUrl != null
                              ? Image.network(
                                  _bannerDownloadUrl!,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: primaryDarkColor
                                          .withAlpha((0.1 * 255).toInt()),
                                      child: Icon(
                                        Icons.image,
                                        size: 40,
                                        color: primaryDarkColor
                                            .withAlpha((0.3 * 255).toInt()),
                                      ),
                                    );
                                  },
                                )
                              : form.bannerImage != null
                                  ? Image.file(
                                      form.bannerImage!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: primaryDarkColor
                                              .withAlpha((0.1 * 255).toInt()),
                                          child: Icon(
                                            Icons.image,
                                            size: 40,
                                            color: primaryDarkColor
                                                .withAlpha((0.3 * 255).toInt()),
                                          ),
                                        );
                                      },
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 40,
                                        color: primaryDarkColor
                                            .withAlpha((0.3 * 255).toInt()),
                                      ),
                                    ),
                        ),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Shop Preview',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryDarkColor,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ShopBrandingScreen(),
                                      ),
                                    );
                                  },
                                  child: Tooltip(
                                    message: 'Edit Images',
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.image,
                                            color: primaryLightColor,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.edit,
                                            color: primaryLightColor,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Logo and Shop Name Row
                            Row(
                              children: [
                                // Logo Image
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primaryDarkColor.withAlpha((0.1 * 255).toInt()),
                                    border: Border.all(
                                      color: primaryDarkColor.withAlpha((0.2 * 255).toInt()),
                                      width: 1,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: _logoDownloadUrl != null
                                        ? Image.network(
                                            _logoDownloadUrl!,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Icon(
                                                Icons.store,
                                                size: 24,
                                                color:
                                                    primaryDarkColor.withAlpha(
                                                        (0.5 * 255).toInt()),
                                              );
                                            },
                                          )
                                        : form.logoImage != null
                                            ? Image.file(
                                                form.logoImage!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Icon(
                                                    Icons.store,
                                                    size: 24,
                                                    color: primaryDarkColor
                                                        .withAlpha((0.5 * 255)
                                                            .toInt()),
                                                  );
                                                },
                                              )
                                            : Icon(
                                                Icons.store,
                                                size: 24,
                                                color:
                                                    primaryDarkColor.withAlpha(
                                                        (0.5 * 255).toInt()),
                                              ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                
                                // Shop Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        form.name ?? 'Shop Name',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: primaryDarkColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '@${form.handle ?? 'shophandle'}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: primaryDarkColor.withAlpha((0.6 * 255).toInt()),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: primaryLightColor.withAlpha((0.1 * 255).toInt()),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          form.category ?? 'Category',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: primaryLightColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Description
                            if (form.description != null && form.description!.isNotEmpty)
                              Text(
                                form.description!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: primaryDarkColor.withAlpha((0.7 * 255).toInt()),
                                  height: 1.4,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Basic Info Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: primaryDarkColor.withAlpha((0.3 * 255).toInt())),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Basic Info',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryDarkColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BasicShopInfoScreen(),
                                  ),
                                );
                              },
                              child: Tooltip(
                                message: 'Edit Basic Info',
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.edit,
                                    color: primaryLightColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Shop Name', form.name ?? 'Not provided'),
                        _buildInfoRow('Handle', '@${form.handle ?? 'Not provided'}'),
                        _buildInfoRow('Category', form.category ?? 'Not provided'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Contact Info Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: primaryDarkColor.withAlpha((0.3 * 255).toInt())),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Contact Info',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryDarkColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ContactInformationScreen(),
                                  ),
                                );
                              },
                              child: Tooltip(
                                message: 'Edit Contact Info',
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.edit,
                                    color: primaryLightColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Email', form.email ?? 'Not provided'),
                        _buildInfoRow('Phone', form.phone ?? 'Not provided'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Social Media Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: primaryDarkColor.withAlpha((0.3 * 255).toInt())),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Social Media',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryDarkColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SocialMediaScreen(),
                                  ),
                                );
                              },
                              child: Tooltip(
                                message: 'Edit Social Media',
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.edit,
                                    color: primaryLightColor,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (form.facebook != null && form.facebook!.isNotEmpty)
                          _buildSocialRow(Icons.facebook, 'Facebook', form.facebook!),
                        if (form.instagram != null && form.instagram!.isNotEmpty)
                          _buildSocialRow(Icons.camera_alt, 'Instagram', form.instagram!),
                        if (form.twitter != null && form.twitter!.isNotEmpty)
                          _buildSocialRow(Icons.alternate_email, 'Twitter', form.twitter!),
                        if ((form.facebook?.isEmpty ?? true) && 
                            (form.instagram?.isEmpty ?? true) && 
                            (form.twitter?.isEmpty ?? true))
                          Text(
                            'No social media accounts added',
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryDarkColor.withAlpha((0.5 * 255).toInt()),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Publish button
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (isEditMode ? updateShop : createShop),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryLightColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                          ),
                        )
                      : Text(
                          isEditMode ? 'Update My Shop' : 'Publish My Shop',
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 12),

                // Save as Draft button with functionality
                InkWell(
                  onTap: (_isLoading || _isDraftSaving) ? null : _saveAsDraft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Show loading spinner while saving draft
                        if (_isDraftSaving) ...[
                          SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  primaryDarkColor),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Icon(
                          Icons.save_outlined,
                          size: 16,
                          color: (_isLoading || _isDraftSaving)
                              ? primaryDarkColor.withAlpha((0.3 * 255).toInt())
                              : primaryDarkColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isDraftSaving ? 'Saving Draft...' : 'Save as Draft',
                          style: TextStyle(
                            color: (_isLoading || _isDraftSaving)
                                ? primaryDarkColor
                                    .withAlpha((0.3 * 255).toInt())
                                : primaryDarkColor,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Progress indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 6 / 6,
                    backgroundColor:
                        primaryDarkColor.withAlpha((0.3 * 255).toInt()),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryLightColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),

                // Step counter
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Step 6 of 6',
                    style: TextStyle(
                      fontSize: 14,
                      color: primaryDarkColor.withAlpha((0.3 * 255).toInt()),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // Show progress bar at top when publishing or saving draft
          if (_isLoading || _isDraftSaving)
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: primaryDarkColor.withAlpha((0.6 * 255).toInt()),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: primaryDarkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialRow(IconData icon, String platform, String handle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: primaryLightColor,
          ),
          const SizedBox(width: 8),
          Text(
            platform,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: primaryDarkColor.withAlpha((0.6 * 255).toInt()),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              handle,
              style: TextStyle(
                fontSize: 14,
                color: primaryDarkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}