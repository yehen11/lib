import 'dart:io';

import 'package:adgo_mobile/modules/seller_gallery/view/screens/seller_gallery_screen.dart';
import 'package:adgo_mobile/modules/seller_gallery/view/screens/video_preview_screen.dart';
import 'package:adgo_mobile/modules/shop/view/controllers/video_state_notofier_provider.dart';
import 'package:adgo_mobile/services/providers/reel_video_provider.dart';
import 'package:adgo_mobile/services/providers/thumbnail_provider.dart';
import 'package:adgo_mobile/services/providers/trigger_repository.dart';
import 'package:adgo_mobile/themes/utils.dart';
import 'package:adgo_mobile/validation/providers/contact_validation_provider.dart';
import 'package:adgo_mobile/validation/providers/website_validation_provider.dart';
import 'package:adgo_mobile/validation/providers/address_validation_provider.dart';
import 'package:adgo_mobile/widgets/CustomAddressWidget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adgo_mobile/widgets/customTextField.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ContactDetailsScreen extends ConsumerStatefulWidget {
  const ContactDetailsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ContactDetailsScreen> createState() => _ContactDetailsScreenState();
}

class _ContactDetailsScreenState extends ConsumerState<ContactDetailsScreen> {
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _addressLine3Controller = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _websiteController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _addressLine3Controller.dispose();
    super.dispose();
  }

  bool _validateFields() {
    final phoneValidation = ref.read(contactValidationProvider);
    final websiteValidation = ref.read(websiteValidationProvider);
    final addressValidation = ref.read(addressValidationProvider);

    if (!phoneValidation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(phoneValidation.error ?? 'Invalid phone number')),
      );
      return false;
    }

    if (_websiteController.text.isNotEmpty && !websiteValidation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(websiteValidation.error ?? 'Invalid website URL')),
      );
      return false;
    }

    if (!addressValidation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(addressValidation.error ?? 'Invalid address')),
      );
      return false;
    }

    return true;
  }

  void _navigateToPreview() {
    if (!_validateFields()) {
      return;
    }

    final form = ref.read(videoFormProvider);
     File? selectedVideoFile = form.videoFile;

     if(selectedVideoFile == null){
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Something went wrong')),
       );
       return;
     }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPreviewScreen(
          videoFile: selectedVideoFile!,
          title: form.title!,
          description: form.description!,
        ),
      ),
    );



  }

  void _processNextStep() async {
    if (!_validateFields()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      setState(() => _isLoading = true);


      final form = ref.read(videoFormProvider);
      final videoFormNotifier = ref.read(videoFormProvider.notifier);

      final userId = form.userId;
      final _selectedVideoFile = form.videoFile;
      final _selectedThumbnailFile = form.thumbnailFile;

      final phone = _phoneController.text.trim();
      final website = _websiteController.text.trim();
      final address = ref.read(addressProvider);

      final videoKey;
      final thumbnailKey;
      final triggerKey;


      //video upload
      if (_selectedVideoFile != null && userId != null) {
         final videoRepo = ref.read(reelVideoRepoProvider);
         final videoName = _selectedVideoFile!.path.split('/').last;

        // 1. Get presigned upload URL
        final response = await videoRepo.getReelVideoUploadUrl(
                            userId: userId, // Replace with actual user ID
                            videoName: videoName,
                          );

         final uploadUrl = response.data['uploadUrl'];
         videoKey = response.data['videoKey'];
         triggerKey = response.data['triggerKey'];

        // 2. Upload the file
          final fileBytes = await _selectedVideoFile.readAsBytes();

         final request = http.Request('PUT', Uri.parse(uploadUrl));
         request.bodyBytes = fileBytes;

        // Optional: set content type for video
         final contentType = 'video/mp4'; // or adjust based on file type
         request.headers['Content-Type'] = contentType;

        final uploadResponse = await request.send();

         if (uploadResponse.statusCode == 200) {
         print('Video uploaded successfully: $videoKey');


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video uploaded successfully. Hold on..')),
        );

         } else {
            throw Exception('Upload failed with status ${uploadResponse.statusCode}');
            }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No video selected')),
        );
        return;
      }


      //video convert trigger
      final repo = ref.read(triggerRepoProvider);
    final triggerResponse = await repo.triggerConvert(
        videoId: videoKey,
        triggerKey: triggerKey,
      );


      if (triggerResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trigger successful. Hold on..')),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trigger failed. Hold on..')),
        );
      }


       //thumbnail upload
      if (_selectedThumbnailFile != null) {
        final thumbnailRepo = ref.read(thumbnailRepoProvider);
        final thumbnailFile = _selectedThumbnailFile!;
        final thumbnailName = thumbnailFile.path.split('/').last;

        // 1. Get presigned upload URL
         final response = await thumbnailRepo.getThumbnailUploadUrl(
          thumbnailVideoName: thumbnailName,
        );

        final uploadUrl = response.data['uploadUrl'];
         thumbnailKey = response.data['thumbnailKey'];

        // 2. Upload the file
        final fileBytes = await thumbnailFile.readAsBytes();

         final request = http.Request('PUT', Uri.parse(uploadUrl));
         request.bodyBytes = fileBytes;

        // Optional: set content type for video
        final contentType = 'video/mp4'; // adjust as needed
        request.headers['Content-Type'] = contentType;

        final uploadResponse = await request.send();


        if (uploadResponse.statusCode == 200) {


          // Save key or move to next screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thumbnail uploaded successfully. Hold on..')),
          );

        } else {
          throw Exception('Upload failed with status ${uploadResponse.statusCode}');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No thumbnail selected')),
        );
        return;
      }



      final title = form.title;
      final description = form.description;


      List<String> missingFields = [];

      if (userId.isEmpty) missingFields.add('userId');
      if (title == null || title.isEmpty) missingFields.add('title');
      if (videoKey == null || videoKey.isEmpty) missingFields.add('videoKey');
      if (thumbnailKey == null || thumbnailKey.isEmpty) missingFields.add('thumbnailKey');

      if (missingFields.isNotEmpty) {
        throw Exception("Missing required fields: ${missingFields.join(', ')}");
      }

      final videoRepo = ref.read(reelVideoRepoProvider);

      final response = await videoRepo.saveVideoEntry(
        authorUserId: userId,
        title: title!,
        description: description,
        thumbnailUrl: thumbnailKey,
        videoEntryId: videoKey,
        tags: ['tag1', 'tag2', 'tag3'],
      );


      if (response.statusCode == 200) {
        String? message = response.data?.toString();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You have successfully posted the video')),
          );

           Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerGalleryScreen()));
        }
      } else {
        throw Exception('Server responded with status: ${response.statusCode}, ${response.data}');
      }
    } on DioException catch (dioError) {
      final msg = dioError.response?.data?.toString() ?? dioError.message;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $msg')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save video: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryDarkColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Contact Details',
          style: TextStyle(color: primaryDarkColor),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contact Number',
                            style: TextStyle(fontSize: 14, color: primaryDarkColor)),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _phoneController,
                          onChanged: (value) {
                            ref.read(contactProvider.notifier).state = value;
                          },
                          validationProvider: contactValidationProvider,
                          icon: Icons.phone,
                          maxLength: 13,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your contact number';
                            }
                            if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                              return 'Please enter a valid 10-digit phone number';
                            }
                            return null;
                          },
                          hintText: '--- ---- ---',
                          keyboardType: TextInputType.phone,
                        ),
                        
                        const SizedBox(height: 32),

                        Text('Item URL',
                            style: TextStyle(fontSize: 14, color: primaryDarkColor)),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: _websiteController,
                          onChanged: (value) {
                            ref.read(websiteProvider.notifier).state = value;
                          },
                          validationProvider: websiteValidationProvider,
                          icon: Icons.link,
                          validator: (value) {
                            if (value != null && value.isNotEmpty) {
                              if (!RegExp(r'^(https?:\/\/)?(www\.)?[a-zA-Z0-9]+\.[a-zA-Z]{2,}').hasMatch(value)) {
                                return 'Please enter a valid website URL';
                              }
                            }
                            return null;
                          },
                          hintText: 'www.example.com',
                          keyboardType: TextInputType.url,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        Text('Address',
                            style: TextStyle(fontSize: 14, color: primaryDarkColor)),
                        const SizedBox(height: 12),
                        CustomAddressWidget(
                          addressLine1Controller: _addressLine1Controller,
                          addressLine2Controller: _addressLine2Controller,
                          addressLine3Controller: _addressLine3Controller,
                          label: null,
                          isRequired: true,
                        ),
                        
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 14),
                
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 3 / 4,
                    backgroundColor: primaryDarkColor.withAlpha((0.1 * 255).toInt()),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryLightColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Step 3 of 4',
                    style: TextStyle(
                      fontSize: 14,
                      color: primaryDarkColor.withAlpha((0.3 * 255).toInt()),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Row(
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
                            color: primaryDarkColor.withAlpha((0.3 * 255).toInt()),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Back',
                          style: TextStyle(color: primaryDarkColor, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                            onPressed: _isLoading ? null : _navigateToPreview,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: primaryDarkColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Preview',
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