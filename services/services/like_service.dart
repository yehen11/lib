import 'package:adgo_mobile/services/core/api_client.dart';
import 'package:adgo_mobile/services/core/endpoints.dart';
import 'package:dio/dio.dart';

class LikeService {
  final _dio = ApiClient.dio;

  /// Like a video
  Future<Response> likeVideo({
    required String videoId,
    required String userId,
  }) {
    return _dio.post(
      Endpoints.likeVideo,
      queryParameters: {
        'videoId': videoId,
        'userId': userId,
      },
    );
  }

  /// Unlike a video
  Future<Response> unlikeVideo({
    required String videoId,
    required String userId,
  }) {
    return _dio.post(
      Endpoints.unlikeVideo,
      queryParameters: {
        'videoId': videoId,
        'userId': userId,
      },
    );
  }

  /// Check if user liked this video
  Future<Response> isLiked({
    required String videoId,
    required String userId,
  }) {
    return _dio.get(
      Endpoints.isLiked,
      queryParameters: {
        'videoId': videoId,
        'userId': userId,
      },
    );
  }

  /// Get total like count of a video
  Future<Response> getLikeCount({
    required String videoId,
  }) {
    return _dio.get(
      Endpoints.getLikeCount,
      queryParameters: {
        'videoId': videoId,
      },
    );
  }
}