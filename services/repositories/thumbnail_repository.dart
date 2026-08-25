import 'package:adgo_mobile/services/services/thumnail_service.dart';
import 'package:dio/dio.dart';

class ThumbnailRepository {
  final ThumbnailService _thumbnailService;

  ThumbnailRepository(this._thumbnailService);

  Future<Response> getThumbnailUploadUrl({
    required String thumbnailVideoName,
  }) async {
    try {
      return await _thumbnailService.getThumbnailUploadUrl(
        thumbnailVideoName: thumbnailVideoName,
      );
    } catch (e, stackTrace) {
      // Handle/log error if needed
      rethrow;
    }
  }

  Future<Response> getThumbnailDownloadUrl({
    required String thumbnailKey,
  }) async {
    try {
      return await _thumbnailService.getThumbnailDownloadUrl(
        thumbnailKey: thumbnailKey,
      );
    } catch (e, stackTrace) {
      // Handle/log error if needed
      rethrow;
    }
  }
}
