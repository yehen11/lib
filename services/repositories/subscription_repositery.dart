import 'package:adgo_mobile/services/services/subscription_service.dart';
import 'package:dio/dio.dart';

class SubscriptionRepository {
  final SubscriptionService _subscriptionService;

  SubscriptionRepository(this._subscriptionService);

  Future<Response> getSubscriptionPlan({
    required int planId,
  }) async {
    try {
      return await _subscriptionService.getSubscriptionPlan(
        planId: planId,
      );
    } catch (e, stackTrace) {
      rethrow;
    }
  }
}