
import 'package:adgo_mobile/services/repositories/video_suggestion_repository.dart';
import 'package:adgo_mobile/services/services/video_suggestion_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final videoSuggestionRepoProvider = Provider<VideoSuggestionRepository>((ref) {
  return VideoSuggestionRepository(VideoSuggestionService());
});


/// Provider to download and cache all videos
final downloadAndCacheAllVideosProvider = FutureProvider<void>((ref) async {
  await ref.read(videoSuggestionRepoProvider).downloadAndCacheAllVideos();
});
