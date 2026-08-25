/*
@Author - Anuruddha
@Date - 2025/02/11
 */

import 'package:adgo_mobile/modules/video_feed/data/apis/video_suggestion_api.dart';
import 'package:adgo_mobile/modules/video_feed/data/apis/youtube_mock_video_api.dart';
import 'package:adgo_mobile/modules/video_feed/data/services/video_service.dart';
import 'package:adgo_mobile/modules/video_feed/data/repositories/video_repo.dart';
import 'package:adgo_mobile/modules/video_feed/model/video_model.dart';
import 'package:adgo_mobile/modules/video_feed/view/controllers/video_grid_controller.dart';
import 'package:adgo_mobile/services/services/video_suggestion_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final _videoApiProvider = Provider<YouTubeMockVideoApi>((ref) => YouTubeMockVideoApi());

final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepository(ref.read(_videoApiProvider));
});

final videoServiceProvider = Provider<VideoService>((ref) {
  return VideoService(ref.read(videoRepositoryProvider));
});


//suggestion
final videoSuggestionServiceProvider = Provider<VideoSuggestionService>((ref) {
  return VideoSuggestionService();
});

final _videoSuggestionApiProvider = Provider<SuggestionVideoApi>((ref) {
  // Pass VideoSuggestionService to SuggestionVideoApi constructor
  final service = ref.read(videoSuggestionServiceProvider);
  return SuggestionVideoApi(service);
});


final videoSuggestionRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepository(ref.read(_videoSuggestionApiProvider));
});


final videoSuggestionProvider = Provider<VideoService>((ref) {
  return VideoService(ref.read(videoSuggestionRepositoryProvider));
});

final videoGridSuggestionProvider = FutureProvider<List<VideoModel>>((ref) async {
  return await ref.read(videoSuggestionProvider).getchVideos();
});

final paginatedVideoGridProvider = StateNotifierProvider<PaginatedVideoGridController, AsyncValue<List<VideoModel>>>(
      (ref) => PaginatedVideoGridController(ref),
);








final videoGridProvider = FutureProvider<List<VideoModel>>((ref) async {
  return await ref.read(videoServiceProvider).getchVideos();
});

final videoUploadProvider = FutureProvider.family<void, VideoModel>((ref, video) async {
  await ref.read(videoServiceProvider).uploadVideo(video);
  ref.invalidate(videoGridProvider); 
  ref.invalidate(addsCountProvider); 
});


final addsCountProvider = FutureProvider<int>((ref) async {
  return await ref.read(videoServiceProvider).getAddCount();
});

final fetchMoreVideosProvider = FutureProvider.family<void, int>((ref, currentAddsCount) async {
  await ref.read(videoServiceProvider).fetchMoreVideos(currentAddsCount);
  ref.invalidate(videoGridProvider); 
  ref.invalidate(addsCountProvider);
});




