import 'package:adgo_mobile/services/core/api_client.dart';
import 'package:adgo_mobile/services/core/endpoints.dart';
import 'package:dio/dio.dart';

class ReelVideoService {
  final _dio = ApiClient.dio;

  /// Get presigned upload URL for reel video
  Future<Response> getReelVideoUploadUrl({
    required String userId,
    required String videoName,
  }) {
    return _dio.get(
      Endpoints.getReelVideoUploadUrl,
      queryParameters: {
        'userId': userId,
        'videoName': videoName,
      },
    );
  }




  /// Save video metadata to backend
  Future<Response> saveVideoEntry({
    required String authorUserId,
    required String title,
    String? description,
    String? thumbnailUrl,
    String? videoEntryId,
    List<String>? tags,
  }) {
    final data = {
      'authorUserId': authorUserId,
      'title': title,
      if (description != null) 'description': description,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      if (videoEntryId != null) 'videoEntryId': videoEntryId,
      if (tags != null) 'tags': tags,
    };

    return _dio.post(
      Endpoints.saveVideoEntry,
      data: data,
    );
  }


}
