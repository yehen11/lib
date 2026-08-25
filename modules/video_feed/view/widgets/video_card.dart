/*
@Author - Anuruddha
@Date - 2025/02/17
 */

import 'dart:io';
import 'package:adgo_mobile/modules/video_feed/model/video_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../routes/routes.dart';
import '../../../../themes/utils.dart';

class VideoCard extends ConsumerWidget {
  final VideoModel video;

  const VideoCard({Key? key, required this.video}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Remove this validation in production
    // Additional safety check: reject video thumbnails at UI level
    if (!_isPhotoThumbnail(video.thumbnail)) {
      print('🚫 VideoCard: Rejecting video thumbnail at UI level: ${video.thumbnail}');
      return const SizedBox.shrink(); // Return empty widget - completely hide
    }
    
    return GestureDetector(
      onDoubleTap: () => _gotoReelScreen(context),
      onTap: () => _gotoReelScreen(context),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo thumbnail as base layer
            _buildThumbnailWidget(video.thumbnail),
            // Title overlay (positioned at bottom)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(8),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    video.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _gotoReelScreen(BuildContext context) {
    // Pass the video data to reel screen
    context.push(Routes.homeReelScreen, extra: video);
  }

  /// Build thumbnail widget handling both local files and network URLs
  Widget _buildThumbnailWidget(String thumbnailPath) {
    // Check if it's a local file path or network URL
    if (_isLocalFilePath(thumbnailPath)) {
      // Handle local file paths
      final file = File(thumbnailPath);
      print('📁 Checking local file: $thumbnailPath');
      print('📁 File exists: ${file.existsSync()}');
      
      if (file.existsSync()) {
        print('✅ Loading local thumbnail: $thumbnailPath');
        return Image.file(
          file,
          fit: BoxFit.contain, // Shows full image without cropping
          errorBuilder: (context, error, stackTrace) {
            print('🚫 Error loading local thumbnail: $thumbnailPath');
            print('🚫 Error: $error');
            return _buildPlaceholder();
          },
        );
      } else {
        print('🚫 Local thumbnail file not found: $thumbnailPath');
        return _buildPlaceholder();
      }
    } else {
      // Handle network URLs
      return CachedNetworkImage(
        imageUrl: thumbnailPath,
        fit: BoxFit.contain, // Shows full image without cropping
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(secondaryDarkColor),
              backgroundColor: Colors.grey,
              strokeWidth: 3,
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          print('🚫 Failed to load network thumbnail: $url - Error: $error');
          return _buildPlaceholder();
        },
      );
    }
  }

  /// Check if the path is a local file path
  bool _isLocalFilePath(String path) {
    // Check for common local file path patterns
    return path.startsWith('/') || // Unix/Android paths
           path.startsWith('file://') || // File URI
           (path.length > 2 && path[1] == ':'); // Windows paths (C:, D:, etc.)
  }

  /// Build placeholder widget for failed thumbnails
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.photo,
          color: Colors.grey[400],
          size: 30,
        ),
      ),
    );
  }

  /// TODO: Remove this method in production
  /// Check if thumbnail URL is a photo (not video) - development safety check
  bool _isPhotoThumbnail(String thumbnailUrl) {
    if (thumbnailUrl.isEmpty) return false;
    
    final uri = Uri.tryParse(thumbnailUrl);
    if (uri == null) return false;
    
    String path = uri.path.toLowerCase();
    
    // Check for photo extensions
    final photoExtensions = ['.jpg', '.jpeg', '.png', '.webp', '.gif'];
    for (String ext in photoExtensions) {
      if (path.endsWith(ext)) {
        return true;
      }
    }
    
    // Check for video extensions (reject these)
    final videoExtensions = ['.mp4', '.avi', '.mov', '.mkv', '.webm', '.m4v'];
    for (String ext in videoExtensions) {
      if (path.endsWith(ext)) {
        return false;
      }
    }
    
    // URL pattern checks
    if (path.contains('image') || path.contains('img') || path.contains('photo')) {
      return true;
    }
    
    if (path.contains('video') || path.contains('vid') || path.contains('movie')) {
      return false;
    }
    
    // Default: if uncertain, reject to be safe
    return false;
  }
}
