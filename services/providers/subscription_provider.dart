import 'package:adgo_mobile/services/repositories/subscription_repositery.dart';
import 'package:adgo_mobile/services/services/subscription_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final subscriptionRepoProvider = Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepository(SubscriptionService());
});

final subscriptionProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, planId) async {
  final repository = ref.watch(subscriptionRepoProvider);
  final response = await repository.getSubscriptionPlan(planId: planId);
  return response.data;
});