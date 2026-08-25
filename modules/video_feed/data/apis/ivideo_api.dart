/*
@Author - Anuruddha
@Date - 2025/02/11
 */


import 'package:adgo_mobile/modules/video_feed/model/video_model.dart';

abstract class IVideoApi {

  IVideoApi();

  Future<List<VideoModel>> getVideos();
  Future<bool> uploadVideo(VideoModel video);
  Future<int> getAddCount();
  Future<bool> fetchMoreVideos(int currentAddsCount);
}
