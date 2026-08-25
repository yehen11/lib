import 'package:adgo_mobile/modules/video_feed/model/video_model.dart';
import 'package:adgo_mobile/services/services/video_suggestion_service.dart';
import 'package:dio/dio.dart';

class VideoSuggestionRepository {
  final VideoSuggestionService _suggestionService;

  VideoSuggestionRepository(this._suggestionService);

  /// Fetch all suggested videos
  Future<List<VideoModel>> getAllVideos() async {
    try {
      return await _suggestionService.getAllVideos();
    } catch (e) {
      rethrow;
    }
  }

  /// Download and cache all videos locally
  Future<void> downloadAndCacheAllVideos() async {
    try {
      await _suggestionService.downloadAndCacheVideos();
    } catch (e) {
      rethrow;
    }
  }
}
