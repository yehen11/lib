import 'package:adgo_mobile/modules/video_feed/data/services/video_service.dart';
import 'package:adgo_mobile/services/services/thumnail_service.dart';
import 'package:adgo_mobile/services/services/video_service.dart';
import 'package:dio/dio.dart';

class ReelVideoRepository {
  final ReelVideoService _videoService;

  ReelVideoRepository(this._videoService);

  Future<Response> getReelVideoUploadUrl({
    required String userId,
    required String videoName,
  }) async {
    try {
      return await _videoService.getReelVideoUploadUrl(
        userId: userId,
        videoName: videoName
      );
    } catch (e, stackTrace) {
      rethrow;
    }
  }



  Future<Response> saveVideoEntry({
    required String authorUserId,
    required String title,
    String? description,
    String? thumbnailUrl,
    String? videoEntryId,
    List<String>? tags,
  }) async {
    try {
      return await _videoService.saveVideoEntry(
        authorUserId: authorUserId,
        title: title,
        description: description,
        thumbnailUrl: thumbnailUrl,
        videoEntryId: videoEntryId,
        tags: tags,
      );
    } catch (e) {
      rethrow;
    }
  }

}
