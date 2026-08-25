import 'package:adgo_mobile/services/repositories/thumbnail_repository.dart';
import 'package:adgo_mobile/services/services/thumnail_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final thumbnailRepoProvider = Provider<ThumbnailRepository>((ref) {
  return ThumbnailRepository(ThumbnailService());
});
