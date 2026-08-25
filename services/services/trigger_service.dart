// lib/services/services/trigger_service.dart

import 'package:adgo_mobile/services/core/api_client.dart';
import 'package:adgo_mobile/services/core/endpoints.dart';
import 'package:dio/dio.dart';

class TriggerService {
  final Dio _dio = ApiClient.dio;

  Future<Response> triggerConvert({
    required String videoId,
    required String triggerKey,
  }) {
    return _dio.post(
      // Endpoints.convert,
      'https://lyypt98p9g.execute-api.ap-south-1.amazonaws.com/prod/convert',
      data: {
        'videoId': videoId,
        'triggerKey': triggerKey,
      },
    );
  }
}
