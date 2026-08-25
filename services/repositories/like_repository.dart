import 'package:adgo_mobile/services/services/like_service.dart';
import 'package:dio/dio.dart';

class LikeRepository {
  final LikeService _likeService;

  LikeRepository(this._likeService);

  /// Like a video
  Future<Response> likeVideo({
    required String videoId,
    required String userId,
  }) async {
    try {
      return await _likeService.likeVideo(
        videoId: videoId,
        userId: userId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Unlike a video
  Future<Response> unlikeVideo({
    required String videoId,
    required String userId,
  }) async {
    try {
      return await _likeService.unlikeVideo(
        videoId: videoId,
        userId: userId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Check if a user liked the video
  Future<Response> isLiked({
    required String videoId,
    required String userId,
  }) async {
    try {
      return await _likeService.isLiked(
        videoId: videoId,
        userId: userId,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get total like count of a video
  Future<Response> getLikeCount({
    required String videoId,
  }) async {
    try {
      return await _likeService.getLikeCount(videoId: videoId);
    } catch (e) {
      rethrow;
    }
  }
}