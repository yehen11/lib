import 'package:adgo_mobile/services/core/api_client.dart';
import 'package:adgo_mobile/services/core/endpoints.dart';
import 'package:dio/dio.dart';

class SubscriptionService {
  final _dio = ApiClient.dio;

  /// Get subscription plan by ID
  Future<Response> getSubscriptionPlan({
    required int planId,
  }) {
    return _dio.get(
      '${Endpoints.subscriptions}/$planId',
    );
  }
}