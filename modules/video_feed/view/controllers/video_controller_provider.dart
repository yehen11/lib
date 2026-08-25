import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

final videoControllerProvider = StateNotifierProvider<VideoControllerManager, Map<String, VideoPlayerController>>(
  (ref) => VideoControllerManager(),
);

class VideoControllerManager extends StateNotifier<Map<String, VideoPlayerController>> {
  String? _currentlyPlayingVideo; // Track the currently playing video

  VideoControllerManager() : super({});

  bool initializeController(String videoUrl) {
    if (!state.containsKey(videoUrl)) {

      print("CACHED URL ======================== " + videoUrl);
      final controller = VideoPlayerController.file(File(videoUrl));

      controller.initialize().then((_) {
        controller.setLooping(true);
        state = {...state, videoUrl: controller};
      }).catchError((error) {});
    }
    return true;
  }

  VideoPlayerController? getController(String videoUrl) {
    return state[videoUrl];
  }

  void playVideo(String videoUrl) {
    // Pause the currently playing video before playing the new one
    if (_currentlyPlayingVideo != null && _currentlyPlayingVideo != videoUrl) {
      state[_currentlyPlayingVideo]?.pause();
    }

    state[videoUrl]?.play();
    _currentlyPlayingVideo = videoUrl;
  }

  void pauseVideo(String videoUrl) {
    state[videoUrl]?.pause();
    if (_currentlyPlayingVideo == videoUrl) {
      _currentlyPlayingVideo = null;
    }
  }

  void pauseAllVideos() {
    for (var controller in state.values) {
      controller.pause();
    }
    _currentlyPlayingVideo = null;
  }

  void disposeController(String videoUrl) {
    state[videoUrl]?.dispose();
    final newState = Map<String, VideoPlayerController>.from(state)..remove(videoUrl);
    state = newState;
  }
}
