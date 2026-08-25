import 'dart:io';
import 'package:adgo_mobile/modules/seller_gallery/view/screens/seller_gallery_screen.dart';
import 'package:adgo_mobile/services/providers/thumbnail_provider.dart';
import 'package:adgo_mobile/themes/Utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../services/providers/reel_video_provider.dart';
import '../../../../services/providers/trigger_repository.dart';
import '../../../../validation/providers/address_validation_provider.dart';
import '../../../shop/view/controllers/video_state_notofier_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../shop/view/screens/welcome_screen.dart';

class VideoPreviewScreen extends ConsumerStatefulWidget {
  final File videoFile;
  final String title;
  final String description;

  const VideoPreviewScreen({
    super.key,
    required this.videoFile,
    required this.title,
    required this.description,
  });

  @override
  ConsumerState<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends ConsumerState<VideoPreviewScreen>
    with WidgetsBindingObserver {
  late VideoPlayerController _controller;
  bool _showControls = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
    setState(() {
      _showControls = true;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }

  void _processNextStep() async {
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
      final tags = form.tags;

      //final address = _addressController.text.trim();
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
            const SnackBar(
                content: Text('Video uploaded successfully. Hold on..')),
          );
        } else {
          throw Exception(
              'Upload failed with status ${uploadResponse.statusCode}');
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
            const SnackBar(
                content: Text('Thumbnail uploaded successfully. Hold on..')),
          );
        } else {
          throw Exception(
              'Upload failed with status ${uploadResponse.statusCode}');
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
      if (thumbnailKey == null || thumbnailKey.isEmpty)
        missingFields.add('thumbnailKey');

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
        tags: tags,
      );

      if (response.statusCode == 200) {
        String? message = response.data?.toString();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You have successfully posted the video')),
          );

          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const WelcomeScreen()));
        }
      } else {
        throw Exception(
            'Server responded with status: ${response.statusCode}, ${response.data}');
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
      backgroundColor: Colors.black,
      body: _controller.value.isInitialized
          ? GestureDetector(
        onTap: _togglePlayPause,
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),

            // Back Button
            SafeArea(
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Play/Pause Overlay Icon
            Center(
              child: ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: _controller,
                builder: (context, value, child) {
                  return AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                      size: 80,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  );
                },
              ),
            ),

            // Bottom Info & Progress
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black.withOpacity(0.6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: Colors.white,
                        backgroundColor: Colors.grey,
                        bufferedColor: Colors.white24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_controller.value.position),
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          _formatDuration(_controller.value.duration),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

                  Positioned(
  bottom: 120,
  left: 0,
  right: 0,
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32.0),
    child: Row(
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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Back',
                style: TextStyle(color: primaryDarkColor, fontSize: 16),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Submit',
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
                  if (_isLoading)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(),
                    ),
          ],
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
