import 'dart:io';
import 'package:adgo_mobile/modules/shop/model/video_form_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoFormNotifier extends StateNotifier<VideoFormModel> {
  VideoFormNotifier() : super(VideoFormModel());

  void updateThumbnailFile(File file) => state = state.copyWith(thumbnailFile: file);
  void updateVideoFile(File file) => state = state.copyWith(videoFile: file);
  void updateThumbnailKey(String key) => state = state.copyWith(thumbnailKey: key);
  void updateVideoKey(String key) => state = state.copyWith(videoKey: key);
  void updateTitle(String title) => state = state.copyWith(title: title);
  void updateDescription(String desc) => state = state.copyWith(description: desc);
  void updatePhone(String phone) => state = state.copyWith(phone: phone);
  void updateWebsite(String website) => state = state.copyWith(website: website);
  void updateAddress(String address) => state = state.copyWith(address: address);
  void updateUserId(String userId) => state = state.copyWith(userId: userId);
  void updateTags(List<String> tags) => state = state.copyWith(tags: tags);

  void updateAll(VideoFormModel newState) => state = newState;
  void reset() => state = VideoFormModel();
}
