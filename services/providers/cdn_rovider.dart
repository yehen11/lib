import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/cdn_repository.dart';
import '../services/cdn_service.dart';

final cdnRepoProvider = Provider<CdnRepository>((ref) {
  return CdnRepository(CdnService());
});
