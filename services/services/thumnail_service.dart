import 'package:adgo_mobile/services/core/api_client.dart';
import 'package:adgo_mobile/services/core/endpoints.dart';
import 'package:dio/dio.dart';

class ThumbnailService {
  final _dio = ApiClient.dio;

  // TODO: Backend - Change parameter name from thumbnailVideoName to thumbnailPhotoName
  /// Get presigned upload URL for photo thumbnail
  Future<Response> getThumbnailUploadUrl({
    required String thumbnailVideoName, // TODO: Rename to thumbnailPhotoName when backend is updated
  }) {
    // Validate photo extension
    if (!_isValidPhotoExtension(thumbnailVideoName)) {
      throw ArgumentError('Invalid photo format. Only JPG, JPEG, PNG, and WebP are allowed.');
    }
    
    return _dio.get(
      Endpoints.getThumbnailUploadUrl,
      queryParameters: {
        'thumbnailVideoName': thumbnailVideoName, // TODO: Change key to thumbnailPhotoName
      },
    );
  }

  /// Validate if the file has a valid photo extension
  bool _isValidPhotoExtension(String filename) {
    final validExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
    final lowerFilename = filename.toLowerCase();
    return validExtensions.any((ext) => lowerFilename.endsWith(ext));
  }

  /// Generate a unique photo thumbnail name with proper extension
  String generatePhotoThumbnailName(String originalFilename) {
    final extension = originalFilename.split('.').last.toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'thumbnail_${timestamp}.$extension';
  }

  /// Get presigned download URL for thumbnail
  Future<Response> getThumbnailDownloadUrl({
    required String thumbnailKey,
  }) {
    return _dio.get(
      Endpoints.getThumbnailDownloadUrl,
      queryParameters: {
        'thumbnailKey': thumbnailKey,
      },
    );
  }
}
