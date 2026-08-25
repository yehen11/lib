import 'dart:io';

import 'package:adgo_mobile/modules/insert_details/view/screens/insert_details_screen.dart';
import 'package:adgo_mobile/modules/shop/view/controllers/video_state_notofier_provider.dart';
import 'package:adgo_mobile/modules/shop/view/controllers/shop_provider.dart';
import 'package:adgo_mobile/modules/shop/view/screens/basic_info.dart';
import 'package:adgo_mobile/modules/shop/view/screens/preview_screen.dart';
import 'package:adgo_mobile/services/providers/reel_video_provider.dart';
import 'package:adgo_mobile/services/repositories/shop_repository.dart';
import 'package:adgo_mobile/themes/Utils.dart';
import 'package:adgo_mobile/widgets/GalleryItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:adgo_mobile/services/providers/shop_provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {

  bool isShopCreated = false;
  bool isLoading = true;
  bool isCreateVideo = false;
  bool hasDraft = false;
  bool isResumingDraft = false;
  File? _selectedVideoFile;
  VideoPlayerController? _videoPlayerController;

  final ShopRepository _shopRepository = ShopRepository();

  // Video validation constants
  static const int maxVideoSizeInBytes = 50 * 1024 * 1024; // 50MB in bytes
  static const int maxVideoLengthInSeconds = 60; // 60 seconds maximum


  @override
  void initState() {
    super.initState();
     _loadShopStatus();
  }

  Future<void> _loadShopStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      print('Loading shop status for userId: $userId');

      if (userId == null) {
        setState(() {
          isShopCreated = false;
          hasDraft = false;
          isLoading = false;
        });
        return;
      }

      // Fetch shop data from backend
      final shopResponse =
          await _shopRepository.getShopsByUserID(userId: userId);

      // Check draft status
      bool draftExists = prefs.containsKey('shop_draft');

      // Single setState - batch all updates
      setState(() {
        // Shop exists if: response OK + data not null + data not empty
        isShopCreated = shopResponse.statusCode == 200 &&
            shopResponse.data != null &&
            shopResponse.data.isNotEmpty;
        hasDraft = draftExists;
        isLoading = false;
      });

        await prefs.setBool('isShopCreated', isShopCreated);

      print(
          'Shop status loaded: isShopCreated=$isShopCreated, hasDraft=$hasDraft');
    } catch (e) {
      print('Error loading shop status: $e');

      // Handle error case - MUST stop loading!
      final prefs = await SharedPreferences.getInstance();
      bool draftExists = prefs.containsKey('shop_draft');

      setState(() {
        isShopCreated = false; // Assume no shop on error
        hasDraft = draftExists;
        isLoading = false;
      });
    }
  }

  Future<void> _resumeDraft() async {
    if (isResumingDraft) return; // Prevent double navigation

    setState(() {
      isResumingDraft = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final draftData = prefs.getString('shop_draft');

      if (draftData != null) {
        // Parse the draft data and update the provider
        final data = draftData.split('|||');
        if (data.length >= 8) {
          final shopForm = ref.read(shopFormProvider.notifier);

          // Update all form fields using correct method names
          shopForm.updateName(data[0]);
          shopForm.updateHandle(data[1]);
          shopForm.updateDescription(data[2]);
          shopForm.updateCategory(data[3]);
          shopForm.updateEmail(data[4]);
          shopForm.updatePhone(data[5]);
          shopForm.updateInstaLink(data[6]);
          shopForm.updateFBLink(data[7]);
          if (data.length > 8) shopForm.updateTWLink(data[8]);

          // Handle image paths - convert paths back to File objects
          if (data.length > 9 && data[9].isNotEmpty) {
            try {
              final logoFile = File(data[9]);
              if (logoFile.existsSync()) {
                shopForm.updateLogoImage(logoFile);
              }
            } catch (e) {
              debugPrint('Error loading logo image: $e');
            }
          }

          if (data.length > 10 && data[10].isNotEmpty) {
            try {
              final bannerFile = File(data[10]);
              if (bannerFile.existsSync()) {
                shopForm.updateBannerImage(bannerFile);
              }
            } catch (e) {
              debugPrint('Error loading banner image: $e');
            }
          }

          // Show success message first
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Draft loaded! Review your shop details and make any changes needed.'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }

          // Navigate to preview screen for review after short delay
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReviewPublishScreen(),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading draft: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isResumingDraft = false;
        });
      }
    }
  }

  // Helper method to format video duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // Helper method to format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Method to validate video file size
  Future<bool> _validateVideoSize(String filePath) async {
    try {
      final file = File(filePath);
      final fileSize = await file.length();

      if (fileSize > maxVideoSizeInBytes) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Video Too Large'),
              content: Text(
                'Please choose a video smaller than 50MB.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  ),
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () => _pickVideo(),
                  child: const Text('Choose Another Video'),
                ),
              ],
            ),
          );
        }
        return false;
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking video size: $e')),
        );
      }
      return false;
    }
  }

  // Method to validate video length
  Future<bool> _validateVideoLength(VideoPlayerController controller) async {
    try {
      // Ensure the video is initialized
      if (!controller.value.isInitialized) {
        await controller.initialize();
      }

      final duration = controller.value.duration;
      final lengthInSeconds = duration.inSeconds;

      if (lengthInSeconds > maxVideoLengthInSeconds) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Video Too Long'),
              content: Text(
                'Please choose a video that is 60 seconds or shorter.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  ),
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () => _pickVideo(),
                  child: const Text('Choose Another Video'),
                ),
              ],
            ),
          );
        }
        return false;
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking video length: $e')),
        );
      }
      return false;
    }
  }


  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      // NEW: Validate video size before proceeding
      final isValidSize = await _validateVideoSize(pickedFile.path);
      
      if (!isValidSize) {
        return;
      }
      _selectedVideoFile = File(pickedFile.path);

      _videoPlayerController?.dispose();
      _videoPlayerController = VideoPlayerController.file(_selectedVideoFile!)
        ..initialize().then((_) async{
          // NEW: Validate video length after initialization
          final isValidLength = await _validateVideoLength(_videoPlayerController!);
          
          if (!isValidLength) {
            // Video is too long, dispose and reset
            _videoPlayerController?.dispose();
            _videoPlayerController = null;
            _selectedVideoFile = null;
            setState(() {});
            return;
          }
          setState(() {}); // Refresh to show video
          _videoPlayerController!.play();

          // NEW: Show success message with file size and duration
          final fileSize = await _selectedVideoFile!.length();
          final duration = _videoPlayerController!.value.duration;
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Video selected successfully (${_formatFileSize(fileSize)}, ${_formatDuration(duration)})'
                ),
              ),
            );
          }
        });
        } else {
      // User cancelled video selection, reset to gallery view
      setState(() {
        isCreateVideo = false;
        _selectedVideoFile = null;
      });
      
      // Dispose video controller if it exists
      _videoPlayerController?.dispose();
      _videoPlayerController = null;
    }
  }



  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    /*if(isShopCreated && !isCreateVideo){
      print("===============isShopCreated && !isCreateVideo==============");
      return SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.fromLTRB( 16, 10, 16, 0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQltIAHUYT6u7GKhj-UIX_fU1Pf0sySCFH_aw&s'),
                        radius: 80,
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Fini Productions",
                              style: TextStyle(
                                  color: primaryDarkColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                          Text("@fini_productions",
                              style: TextStyle(
                                  color: primaryDarkColor
                                      .withAlpha((0.5 * 255).toInt()),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                          Text("25 videos",
                              style: TextStyle(
                                  color: primaryDarkColor
                                      .withAlpha((0.5 * 255).toInt()),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(
                    color: primaryDarkColor.withAlpha((0.2 * 255).toInt()),
                    thickness: 1,
                  ),
                  GalleryItem(
                    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQltIAHUYT6u7GKhj-UIX_fU1Pf0sySCFH_aw&s',
                    title: 'Fanta from PS around Colombo',
                    duration: '15h 23min',
                    views: '26 k',
                    bookmarks: '236',
                  ),
                  const SizedBox(height: 10),
                  
                  GalleryItem(
                    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS2d7bF1q2WBQnHUhqaR2OuxjFiv_EIWBwqow&s',
                    title: 'Ice Cream from Fini around Colombo',
                    duration: '24h 00min',
                    views: '2 k',
                    bookmarks: '100',
                  ),
                  const SizedBox(height: 10),
                  
                  GalleryItem(
                    imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSanZcPmlTnx5BIuKxqObWtFncZXQdkdpIp1A&s',
                    title: 'Rice from Fini around Colombo',
                    duration: '15h 23min',
                    views: '2 k',
                    bookmarks: '100',
                  ),
                  const SizedBox(height: 20),
                  ]
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              setState(() {
                isCreateVideo = true;
              });
              await _pickVideo();
            },
            child: const Icon(Icons.add),
          ),
        ),
      );
    }*/


    if (isShopCreated && !isCreateVideo) {
      print("===============isShopCreated && !isCreateVideo==============");

      return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final prefs = snapshot.data!;
          final userId = prefs.getString("userId");

          print("USER_ID");
          print(userId);

          if (userId == null) {
            return const Scaffold(
              body: Center(child: Text("User ID not found")),
            );
          }

          final shopAsync = ref.watch(shopsByUserProvider(userId));

          return shopAsync.when(
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Scaffold(
              body: Center(child: Text("Error: $err")),
            ),
            data: (shops) {
              if (shops.isEmpty) {
                return const Scaffold(
                  body: Center(child: Text("No shop found for this user.")),
                );
              }

              final shop = shops.first;

              return SafeArea(
                child: Scaffold(
                  body: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /// -----------------------------
                          /// PROFILE SECTION
                          /// -----------------------------
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundImage: NetworkImage(
                                  'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQltIAHUYT6u7GKhj-UIX_fU1Pf0sySCFH_aw&s',
                                ),
                                radius: 80,
                              ),
                              const SizedBox(width: 15),

                              /// ONLY shop.name is dynamic
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      shop.name,
                                      style: TextStyle(
                                        color: primaryDarkColor,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '@${shop.handle}',
                                      style: TextStyle(
                                        color:
                                            primaryDarkColor.withOpacity(0.5),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "25 videos",
                                      style: TextStyle(
                                        color:
                                            primaryDarkColor.withOpacity(0.5),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Edit Shop Button
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                // Load shop data into form before navigating
                                final shopForm =
                                    ref.read(shopFormProvider.notifier);
                                shopForm.updateShopId(shop.shopId);
                                shopForm.updateName(shop.name);
                                shopForm.updateHandle(shop.handle);
                                shopForm.updateDescription(shop.description!);
                                shopForm.updateCategory(shop.category);
                                shopForm.updateEmail(shop.contact.email!);
                                shopForm.updatePhone(shop.contact.phoneNumber!);

                                // Load social media links
                                final socialLinks =
                                    shop.contact.socialMediaLinks;
                                if (socialLinks.containsKey('facebook')) {
                                  shopForm
                                      .updateFBLink(socialLinks['facebook']!);
                                }
                                if (socialLinks.containsKey('instagram')) {
                                  shopForm.updateInstaLink(
                                      socialLinks['instagram']!);
                                }
                                if (socialLinks.containsKey('twitter')) {
                                  shopForm
                                      .updateTWLink(socialLinks['twitter']!);
                                }

                                // Set URLs (images are already uploaded)
                                shopForm.updateBannerUrl(shop.bannerUrl!);
                                shopForm.updateLogoUrl(shop.logoUrl!);

                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ReviewPublishScreen(),
                                  ),
                                );
                                // Always refresh when returning from edit (result may be null)
                                // Invalidate provider cache to force refresh
                                ref.invalidate(shopsByUserProvider);
                                setState(() {
                                  isLoading = true;
                                });
                                _loadShopStatus();
                              },
                              icon: const Icon(Icons.settings, size: 18),
                              label: const Text(
                                "Edit Shop",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: primaryDarkColor.withOpacity(0.3),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                          Divider(
                            color: primaryDarkColor.withOpacity(0.2),
                            thickness: 1,
                          ),

                          /// -----------------------------
                          /// STATIC GALLERY ITEMS
                          /// -----------------------------
                         /* GalleryItem(
                            imageUrl:
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQltIAHUYT6u7GKhj-UIX_fU1Pf0sySCFH_aw&s',
                            title: 'Fanta from PS around Colombo',
                            duration: '15h 23min',
                            views: '26 k',
                            bookmarks: '236',
                          ),
                          const SizedBox(height: 10),

                          GalleryItem(
                            imageUrl:
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS2d7bF1q2WBQnHUhqaR2OuxjFiv_EIWBwqow&s',
                            title: 'Ice Cream from Fini around Colombo',
                            duration: '24h 00min',
                            views: '2 k',
                            bookmarks: '100',
                          ),
                          const SizedBox(height: 10),

                          GalleryItem(
                            imageUrl:
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSanZcPmlTnx5BIuKxqObWtFncZXQdkdpIp1A&s',
                            title: 'Rice from Fini around Colombo',
                            duration: '15h 23min',
                            views: '2 k',
                            bookmarks: '100',
                          ),*/

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  floatingActionButton: FloatingActionButton(
                    onPressed: () async {
                      setState(() {
                        isCreateVideo = true;
                      });
                      await _pickVideo();
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
              );
            },
          );
        },
      );
    }



    if (isCreateVideo) {
      print("===============inside iscreate video==============");
      if (_selectedVideoFile == null || _videoPlayerController == null || !_videoPlayerController!.value.isInitialized) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        body: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController!),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await _pickVideo();
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: primaryLightColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Select',
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });

                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final userId = prefs.getString('userId');

                            if (_selectedVideoFile != null && userId != null) {
                              final videoFormNotifier =
                                  ref.read(videoFormProvider.notifier);

                              videoFormNotifier
                                  .updateVideoFile(_selectedVideoFile!);
                              videoFormNotifier.updateUserId(userId);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Video saved successfully')),
                              );

                              _videoPlayerController?.pause();
                              _videoPlayerController?.dispose();
                              _videoPlayerController = null;
                              //success case
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const InsertDetailsScreen(),
                                ),
                              ).then((_) {
                                setState(() {
                                  isCreateVideo = false;
                                  _selectedVideoFile = null;
                                });
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('No video selected')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Video upload failed: $e')),
                            );
                          } finally {
                            setState(() {
                              isLoading = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: primaryLightColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Upload',
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }


    if(!isShopCreated){
      print("===============shop not created==============");
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Hello There!',
                  style: TextStyle(
                    fontSize: 24,
                    color: primaryDarkColor,
                  ),
                ),
                const SizedBox(height: 30),
                Image.network(
                  'https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEjluxvpQMYDZn1gkSlgZhJtMgxugA2-PSne-iowCLjnO1omQ4pk0_5ZL7ldMEIdQEzh0oI4Wc6ihg_gyOn7cNcaCYajBuEuNTtHcT46uDOhvfW7lfAiTD7y3EdoLmkERQ9Hg3QpFubKNkTyZ72904-_fADPcnBif20rOxWu0QB8TgsdoF352UgCgjxMvQf1/s320/Welcome-cuate.png',
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                Text(
                  'Set Up Your Shop',
                  style: TextStyle(
                    fontSize: 18,
                    color: primaryDarkColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Create your shop in just a few steps to start selling',
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryDarkColor.withAlpha((0.3 * 255).toInt()),
                  ),
                ),
                // Debug info to show draft status
                if (hasDraft)
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green, width: 1),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, color: Colors.green, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Draft found! You can review and continue your setup',
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 40),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Show Resume Draft button if draft exists
                        if (hasDraft)
                          SizedBox(
                            width: 200,
                            child: ElevatedButton(
                              onPressed: isResumingDraft ? null : _resumeDraft,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: whiteColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: isResumingDraft
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.preview,
                                            size: 20, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(
                                          'Review Draft',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        if (hasDraft) const SizedBox(height: 16),
                        // Always show Get Started button
                        SizedBox(
                          width: 150,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const BasicShopInfoScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryLightColor,
                              foregroundColor: whiteColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              hasDraft ? 'Start Fresh' : 'Get Started',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );

  }

}
