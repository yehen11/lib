import 'package:adgo_mobile/services/services/like_service.dart';
import 'package:adgo_mobile/services/repositories/like_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final likeRepoProvider = Provider<LikeRepository>((ref) {
  return LikeRepository(LikeService());
});