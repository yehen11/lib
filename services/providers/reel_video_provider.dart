import 'package:adgo_mobile/modules/video_feed/data/repositories/video_repo.dart';
import 'package:adgo_mobile/services/repositories/video_repository.dart';
import 'package:adgo_mobile/services/services/video_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final reelVideoRepoProvider = Provider<ReelVideoRepository>((ref) {
  return ReelVideoRepository(ReelVideoService());
});

