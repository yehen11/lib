import 'package:adgo_mobile/modules/video_feed/view/controllers/video_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/video_model.dart';

class PaginatedVideoGridController extends StateNotifier<AsyncValue<List<VideoModel>>> {
  final Ref ref;
  final List<VideoModel> _videos = [];
  int _page = 0;
  final int _limit = 12;
  bool _isLoading = false;
  bool hasMore = true;

  PaginatedVideoGridController(this.ref) : super(const AsyncValue.loading()) {
    _loadInitialVideos();
  }

  Future<void> _loadInitialVideos() async {
    try {
      final service = ref.read(videoSuggestionProvider); // use ref directly
      final all = await service.getchVideos();

      if (all.isEmpty) {
        state = const AsyncValue.data([]);
        hasMore = false;
        return;
      }

      final pageVideos = all.take(_limit).toList();
      _videos.addAll(pageVideos);
      state = AsyncValue.data(_videos);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || !hasMore) return;
    _isLoading = true;
    try {
      final service = ref.read(videoSuggestionProvider);
      final all = await service.getchVideos();

      _page++;
      final start = _page * _limit;
      if (start >= all.length) {
        hasMore = false;
        return;
      }

      final pageVideos = all.skip(start).take(_limit).toList();
      _videos.addAll(pageVideos);
      state = AsyncValue.data([..._videos]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isLoading = false;
    }
  }
}
