import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:adgo_mobile/services/providers/reel_video_provider.dart';
import 'package:adgo_mobile/services/providers/thumbnail_provider.dart';
import 'package:adgo_mobile/services/providers/trigger_repository.dart';
import 'package:adgo_mobile/themes/utils.dart';

class VideoUploadTestScreen extends ConsumerStatefulWidget {
  const VideoUploadTestScreen({super.key});

  @override
  ConsumerState<VideoUploadTestScreen> createState() => _VideoUploadTestScreenState();
}

class _VideoUploadTestScreenState extends ConsumerState<VideoUploadTestScreen> {
  File? videoFile;
  File? thumbnailPhotoFile; // Changed from thumbnailVideoFile to thumbnailPhotoFile

  VideoPlayerController? _videoController;
  // Removed _thumbnailController - no longer needed for photo thumbnails

  final picker = ImagePicker();
  bool _isLoading = false;

  // Photo aspect ratio validation for vertical mobile video format
  static const double targetAspectRatio = 9.0 / 16.0; // 9:16 aspect ratio (vertical)
  static const double minAspectRatio = 0.4; // Minimum acceptable ratio (2:5 - very tall)
  static const double maxAspectRatio = 0.8; // Maximum acceptable ratio (4:5 - less tall)

  Future<File?> _pickVideo() async {
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<File?> _pickThumbnailPhoto() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // Compress image quality
    );
    
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final isValid = await _validatePhotoDimensions(file);
      if (isValid) {
        return file;
      }
    }
    return null;
  }

  Future<bool> _validatePhotoDimensions(File photoFile) async {
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
        
        _showDimensionError(
          'Photo Aspect Ratio Not Suitable for Video Grid',
          'Please select a photo that fits well in the 3x3 video grid.\n'
          'Current ratio: ${aspectRatio.toStringAsFixed(2)}:1 ($ratioDescription)\n'
          'Recommended: Around ${targetAspectRatio.toStringAsFixed(2)}:1 (9:16 vertical format)\n'
          'Acceptable range: ${minAspectRatio.toStringAsFixed(1)}:1 to ${maxAspectRatio.toStringAsFixed(1)}:1'
        );
        return false;
      }
      
      // Photo is valid
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
  
  void _showDimensionError(String title, String message) {
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
                _selectThumbnailPhoto();
              },
              child: const Text('Choose Another Photo'),
            ),
          ],
        ),
      );
    }
  }
  
  Future<void> _selectThumbnailPhoto() async {
    final picked = await _pickThumbnailPhoto();
    if (picked != null) {
      setState(() => thumbnailPhotoFile = picked);
    }
  }

  Future<void> _initializeVideoController() async {
    if (videoFile != null) {
      _videoController?.dispose();
      _videoController = VideoPlayerController.file(videoFile!)
        ..setLooping(true)
        ..initialize().then((_) => setState(() {}));
    }
  }

  Future<void> _uploadAndSave() async {
    // TODO: change the variable names after testing
    if (videoFile == null || thumbnailPhotoFile == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select both video and thumbnail photo.")),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final reelRepo = ref.read(reelVideoRepoProvider);
      final thumbRepo = ref.read(thumbnailRepoProvider);
      final triggerRepo = ref.read(triggerRepoProvider);

      // Get current user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User not authenticated. Please log in.")),
          );
        }
        return;
      }
      final title = 'Dummy Title';
      final description = 'This is a test upload';
      final tags = ['test', 'upload'];

      final videoName = videoFile!.path.split('/').last;
      final videoUrlResp = await reelRepo.getReelVideoUploadUrl(userId: userId, videoName: videoName);
      final videoUploadUrl = videoUrlResp.data['uploadUrl'];
      final videoKey = videoUrlResp.data['videoKey'];
      final triggerKey = videoUrlResp.data['triggerKey'];

      final videoBytes = await videoFile!.readAsBytes();
      final videoRequest = http.Request('PUT', Uri.parse(videoUploadUrl))
        ..bodyBytes = videoBytes
        ..headers['Content-Type'] = 'video/mp4';
      final videoResp = await videoRequest.send();
      if (videoResp.statusCode != 200) throw Exception("Video upload failed");

      final triggerResp = await triggerRepo.triggerConvert(videoId: videoKey, triggerKey: triggerKey);
      if (triggerResp.statusCode != 200) throw Exception("Trigger failed");

      final thumbnailName = thumbnailPhotoFile!.path.split('/').last;
      final thumbResp = await thumbRepo.getThumbnailUploadUrl(thumbnailVideoName: thumbnailName); // TODO: Backend still expects thumbnailVideoName
      final thumbUploadUrl = thumbResp.data['uploadUrl'];
      final thumbnailKey = thumbResp.data['thumbnailKey'];

      final thumbBytes = await thumbnailPhotoFile!.readAsBytes();
      
      // Determine content type based on file extension
      String contentType = 'image/jpeg'; // default
      final extension = thumbnailName.toLowerCase().split('.').last;
      switch (extension) {
        case 'png':
          contentType = 'image/png';
          break;
        case 'webp':
          contentType = 'image/webp';
          break;
        case 'jpg':
        case 'jpeg':
        default:
          contentType = 'image/jpeg';
          break;
      }
      
      final thumbRequest = http.Request('PUT', Uri.parse(thumbUploadUrl))
        ..bodyBytes = thumbBytes
        ..headers['Content-Type'] = contentType;
      final thumbUploadResp = await thumbRequest.send();
      print("Thumbnail photo upload response: ${thumbUploadResp.statusCode}");
      if (thumbUploadResp.statusCode != 200) throw Exception("Thumbnail photo upload failed");

      final saveResp = await reelRepo.saveVideoEntry(
        authorUserId: userId,
        title: title,
        description: description,
        thumbnailUrl: thumbnailKey,
        videoEntryId: videoKey,
        tags: tags,
      );

      print("Video entry save response: ${saveResp.statusCode}");
      if (saveResp.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Test video uploaded successfully.")),
          );
        }
      } else {
        throw Exception("Failed to save video entry");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test Upload"), backgroundColor: primaryDarkColor),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final picked = await _pickVideo();
                  if (picked != null) {
                    setState(() => videoFile = picked);
                    await _initializeVideoController();
                  }
                },
                child: Text(videoFile != null ? "Video Selected ✅" : "Pick Main Video"),
              ),
              if (_videoController?.value.isInitialized ?? false)
                AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selectThumbnailPhoto,
                child: Text(thumbnailPhotoFile != null ? "Thumbnail Photo Selected ✅" : "Pick Thumbnail Photo"),
              ),
              if (thumbnailPhotoFile != null)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      thumbnailPhotoFile!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _uploadAndSave,
                style: ElevatedButton.styleFrom(backgroundColor: primaryLightColor),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Upload & Save Dummy"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
