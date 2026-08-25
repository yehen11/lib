import 'dart:io';
import 'dart:ui' as ui;

import 'package:adgo_mobile/modules/contact_details/view/screens/contact_details_screen.dart';
import 'package:adgo_mobile/modules/insert_details/view/screens/tag_selection_screen.dart';
import 'package:adgo_mobile/modules/shop/view/controllers/video_state_notofier_provider.dart';
import 'package:adgo_mobile/services/providers/thumbnail_provider.dart';
import 'package:adgo_mobile/themes/utils.dart';
import 'package:adgo_mobile/validation/providers/description_validation_provider.dart';
import 'package:adgo_mobile/validation/providers/title_validation_provider.dart';
import 'package:adgo_mobile/validation/providers/video_dexcription_validation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adgo_mobile/widgets/customTextField.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

final videoThumbnailProvider = StateProvider<bool>((ref) => false);

class InsertDetailsScreen extends ConsumerStatefulWidget {
  const InsertDetailsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<InsertDetailsScreen> createState() => _InsertDetailsScreenState();
}

class _InsertDetailsScreenState extends ConsumerState<InsertDetailsScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _useInbuiltThumbnail = false;
  bool _thumbnailSelected = false;
  bool _isLoading = false;
  List<String> _selectedTags = [];
  bool _tagsInitialized = false;

  VideoPlayerController? _videoController;
  String? _selectedVideoPath;

  // NEW: Video size filter constants
  static const int maxVideoSizeInBytes = 20 * 1024 * 1024; // 20MB in bytes

  // NEW: Video length filter constants
  static const int maxVideoLengthInSeconds = 5; // 5 seconds maximum

  // Photo aspect ratio validation for vertical mobile video format
  static const double targetAspectRatio = 9.0 / 16.0; // 9:16 aspect ratio (vertical)
  static const double minAspectRatio = 0.4; // Minimum acceptable ratio (2:5 - very tall)
  static const double maxAspectRatio = 0.8; // Maximum acceptable ratio (4:5 - less tall)

  @override
  void dispose() {
    _videoController?.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    final titleValidation = ref.read(titleValidationProvider);
    final descriptionValidation = ref.read(videoDescriptionValidationProvider);

    if (!titleValidation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(titleValidation.error ?? 'Invalid video title')),
      );
      return false;
    }

    if (!descriptionValidation.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(descriptionValidation.error ?? 'Invalid description')),
      );
      return false;
    }

    if (!_useInbuiltThumbnail && !_thumbnailSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a thumbnail or use the inbuilt option')),
      );
      return false;
    }

    if (_selectedTags.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 3 tags')),
      );
      return false;
    }

    return true;
  }

  // NEW: Helper method to format video duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  // NEW: Helper method to format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // NEW: Helper method to remove thumbnail
  void _removeThumbnail() {
    setState(() {
      _thumbnailSelected = false;
      _selectedVideoPath = null;
    });

    _videoController?.dispose();
    _videoController = null;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thumbnail removed')),
    );
  }

  // NEW: Method to validate video file size
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
                'Please choose a video smaller than 20MB.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _selectThumbnail();
                  },
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

// NEW: Method to validate video length
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
                'Please choose a video that is 5 seconds or shorter.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _selectThumbnail();
                  },
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



  void _processNextStep() async {
    if (!_validateFields()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      if (!_useInbuiltThumbnail && _selectedVideoPath != null) {
        //final thumbnailRepo = ref.read(thumbnailRepoProvider);
        final thumbnailFile = File(_selectedVideoPath!);
        //final thumbnailName = thumbnailFile.path.split('/').last;

        // 1. Get presigned upload URL
       /* final response = await thumbnailRepo.getThumbnailUploadUrl(
          thumbnailVideoName: thumbnailName,
        );*/

        //final uploadUrl = response.data['uploadUrl'];
        //final thumbnailKey = response.data['thumbnailKey'];

        // 2. Upload the file
        //final fileBytes = await thumbnailFile.readAsBytes();

       // final request = http.Request('PUT', Uri.parse(uploadUrl));
       // request.bodyBytes = fileBytes;

        // Optional: set content type for video
        //final contentType = 'video/mp4'; // adjust as needed
        //request.headers['Content-Type'] = contentType;

        //final uploadResponse = await request.send();



        final videoFormNotifier = ref.read(videoFormProvider.notifier);

        videoFormNotifier.updateTitle(_titleController.text);
        videoFormNotifier.updateThumbnailFile(thumbnailFile);
        videoFormNotifier.updateDescription(_descriptionController.text);
        videoFormNotifier.updateTags(_selectedTags);


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thumbnail saved successfully')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ContactDetailsScreen()),
        );

        /*if (uploadResponse.statusCode == 200) {
          print('Thumbnail uploaded successfully: $thumbnailKey');


          final videoFormNotifier = ref.read(videoFormProvider.notifier);

          videoFormNotifier.updateTitle(_titleController.text);
          videoFormNotifier.updateThumbnailFile(thumbnailFile);
          videoFormNotifier.updateThumbnailKey(thumbnailKey);
          videoFormNotifier.updateDescription(_descriptionController.text);


          // Save key or move to next screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thumbnail saved successfully')),
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContactDetailsScreen()),
          );
        } else {
          throw Exception('Upload failed with status ${uploadResponse.statusCode}');
        }*/
      } else {
        // If using inbuilt thumbnail, continue without upload
        final videoFormNotifier = ref.read(videoFormProvider.notifier);
        videoFormNotifier.updateTitle(_titleController.text);
        videoFormNotifier.updateDescription(_descriptionController.text);
        videoFormNotifier.updateTags(_selectedTags);
        
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ContactDetailsScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  void _selectThumbnail() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      
      // Validate photo dimensions first
      final isDimensionValid = await _validateThumbnailPhotoDimensions(file);
      if (!isDimensionValid) {
        return; // Error dialogs are shown in validation method
      }
      
      // Validate photo file size (limit to 5MB for thumbnails)
      final fileSize = await file.length();
      const maxThumbnailSize = 5 * 1024 * 1024; // 5MB

      if (fileSize > maxThumbnailSize) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please choose a photo smaller than 5MB')),
          );
        }
        return;
      }
      
      setState(() {
        _thumbnailSelected = true;
        _selectedVideoPath = pickedFile.path; // TODO: Rename this variable
      });
      
      // Show success message with file size
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Thumbnail photo selected successfully (${_formatFileSize(fileSize)})')),
        );
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No photo selected')),
      );
    }
  }

  Future<bool> _validateThumbnailPhotoDimensions(File photoFile) async {
    try {
      final bytes = await photoFile.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;
      
      final width = image.width;
      final height = image.height;
      final aspectRatio = width / height;
      
      // Only check aspect ratio for vertical mobile video format (3x3 grid display)
      if (aspectRatio < minAspectRatio || aspectRatio > maxAspectRatio) {
        String ratioDescription;
        if (aspectRatio < minAspectRatio) {
          ratioDescription = 'too tall (ultra-portrait)';
        } else {
          ratioDescription = 'too wide (not portrait enough)';
        }
        
        _showThumbnailDimensionError(
          'Photo Aspect Ratio Not Suitable for Video Grid',
          'Please select a photo that fits well in the 3x3 video grid.\n'
          'Current ratio: ${aspectRatio.toStringAsFixed(2)}:1 ($ratioDescription)\n'
          'Recommended: Around ${targetAspectRatio.toStringAsFixed(2)}:1 (9:16 vertical format)\n'
          'Acceptable range: ${minAspectRatio.toStringAsFixed(1)}:1 to ${maxAspectRatio.toStringAsFixed(1)}:1'
        );
        return false;
      }
      
      // Photo dimensions are valid
      return true;
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error validating photo: $e')),
        );
      }
      return false;
    }
  }
  
  void _showThumbnailDimensionError(String title, String message) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _selectThumbnail();
              },
              child: const Text('Choose Another Photo'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize tags from video form if they exist (only once)
    if (!_tagsInitialized) {
      final form = ref.read(videoFormProvider);
      if (form.tags != null && form.tags!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _selectedTags = form.tags!;
              _tagsInitialized = true;
            });
          }
        });
      } else {
        _tagsInitialized = true;
      }
    }
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryDarkColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Insert Details', style: TextStyle(color: primaryDarkColor)),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Title
                      Text('Video Title', style: TextStyle(fontSize: 14, color: primaryDarkColor)),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _titleController,
                        onChanged: (value) {
                          ref.read(titleProvider.notifier).state = value;
                        },
                        validationProvider: titleValidationProvider,
                        icon: Icons.title,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your video title';
                          if (value.length > 50) return 'Title must be 50 characters or less';
                          return null;
                        },
                        hintText: 'Enter video title',
                        keyboardType: TextInputType.text,
                        maxLength: 50,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text("max 50 characters",
                            style: TextStyle(color: primaryDarkColor.withAlpha(80), fontSize: 12)),
                      ),
                      const SizedBox(height: 16),
                  
                      // Thumbnail section
                      Text('Video Thumbnail', style: TextStyle(fontSize: 14, color: primaryDarkColor)),
                      const SizedBox(height: 12),
                  
                      // Video preview container
                      Center(
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: _useInbuiltThumbnail
                                  ? null
                                  : _selectThumbnail,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  color: primaryLightColor.withAlpha(25),
                                  border: Border.all(
                                    color: _useInbuiltThumbnail
                                        ? primaryDarkColor.withAlpha(80)
                                        : primaryDarkColor,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _useInbuiltThumbnail || !_thumbnailSelected
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _thumbnailSelected
                                                ? 'Photo Selected'
                                                : 'No Photo Selected',
                                            style: TextStyle(
                                              color: _useInbuiltThumbnail
                                                  ? primaryDarkColor
                                                      .withAlpha(80)
                                                  : primaryDarkColor,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Icon(
                                            Icons.add_a_photo,
                                            color: _useInbuiltThumbnail
                                                ? primaryDarkColor
                                                    .withAlpha(80)
                                                : primaryDarkColor,
                                          ),
                                          // Updated size limit hints for photos
                                          if (!_useInbuiltThumbnail) ...[
                                            const SizedBox(height: 5),
                                            Text(
                                              'Max 5MB',
                                              style: TextStyle(
                                                color: primaryDarkColor
                                                    .withAlpha(60),
                                                fontSize: 10,
                                              ),
                                            ),
                                            Text(
                                              'JPG, PNG, WebP',
                                              style: TextStyle(
                                                color: primaryDarkColor
                                                    .withAlpha(60),
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ],
                                      )
                                    : ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        child: Image.file(
                                          File(_selectedVideoPath!),
                                          fit: BoxFit.cover,
                                          width: 150,
                                          height: 150,
                                        ),
                                      ),
                              ),
                            ),
                            if (!_useInbuiltThumbnail && _thumbnailSelected)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: _removeThumbnail,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child:
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Icon(Icons.close, color: Colors.red,size: 12),
                                        ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  
                      const SizedBox(height: 16),
                  
                      // Description
                      Text('Description', style: TextStyle(fontSize: 14, color: primaryDarkColor)),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _descriptionController,
                        onChanged: (value) {
                          ref.read(videoDescriptionProvider.notifier).state = value;
                        },
                        validationProvider: videoDescriptionValidationProvider,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your video description';
                          if (value.length > 350) return 'Description must be 350 characters or less';
                          return null;
                        },
                        hintText: 'Your description here',
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text("max 350 characters",
                            style: TextStyle(color: primaryDarkColor.withAlpha(80), fontSize: 12)),
                      ),
                      const SizedBox(height: 16),
                      
                      // Tags section
                      Text('Tags', style: TextStyle(fontSize: 14, color: primaryDarkColor)),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push<List<String>>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TagSelectionScreen(
                                initialTags: _selectedTags,
                              ),
                            ),
                          );
                          if (result != null) {
                            setState(() {
                              _selectedTags = result;
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: whiteColor,
                            border: Border.all(
                              color: primaryDarkColor.withAlpha(80),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.label_outline,
                                color: primaryDarkColor,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedTags.isEmpty
                                          ? 'Select tags (3-25 required)'
                                          : '${_selectedTags.length} tag${_selectedTags.length == 1 ? '' : 's'} selected',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _selectedTags.isEmpty
                                            ? primaryDarkColor.withAlpha(120)
                                            : primaryDarkColor,
                                        fontWeight: _selectedTags.isEmpty
                                            ? FontWeight.normal
                                            : FontWeight.w500,
                                      ),
                                    ),
                                    if (_selectedTags.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: _selectedTags.take(5).map((tag) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: primaryLightColor.withAlpha(25),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: primaryLightColor.withAlpha(100),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              tag,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: primaryDarkColor,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      if (_selectedTags.length > 5)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            '+ ${_selectedTags.length - 5} more',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: primaryDarkColor.withAlpha(120),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: primaryDarkColor.withAlpha(120),
                              ),
                            ],
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
                    value: 2 / 4,
                    backgroundColor: primaryDarkColor.withAlpha(25),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryLightColor),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Step 2 of 4',
                    style: TextStyle(fontSize: 14, color: primaryDarkColor.withAlpha(80)),
                  ),
                ),
                const SizedBox(height: 8),
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
                          side: BorderSide(color: primaryDarkColor.withAlpha(80)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text('Back', style: TextStyle(color: primaryDarkColor, fontSize: 16)),
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
