import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages which video is currently visible and should be playing
class VideoPlayerManager extends StateNotifier<int> {
  VideoPlayerManager() : super(0);

  /// Update the current visible video index
  void setCurrentIndex(int index) {
    if (state != index) {
      state = index;
    }
  }

  /// Get current playing index
  int get currentIndex => state;
}

/// Provider for video player manager
final videoPlayerManagerProvider = StateNotifierProvider<VideoPlayerManager, int>((ref) {
  return VideoPlayerManager();
});
