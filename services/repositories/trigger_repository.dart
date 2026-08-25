// lib/modules/video_feed/data/repositories/trigger_repository.dart

import 'package:adgo_mobile/services/services/trigger_service.dart';
import 'package:dio/dio.dart';

class TriggerRepository {
  final TriggerService _triggerService;

  TriggerRepository(this._triggerService);

  Future<Response> triggerConvert({
    required String videoId,
    required String triggerKey,
  }) async {
    try {
      return await _triggerService.triggerConvert(
        videoId: videoId,
        triggerKey: triggerKey,
      );
    } catch (e) {
      rethrow;
    }
  }
}
