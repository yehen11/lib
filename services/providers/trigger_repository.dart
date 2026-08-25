// services/providers/trigger_provider.dart (or wherever you keep providers)

import 'package:adgo_mobile/services/repositories/trigger_repository.dart';
import 'package:adgo_mobile/services/services/trigger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final triggerRepoProvider = Provider<TriggerRepository>((ref) {
  return TriggerRepository(TriggerService());
});
