/*
@Author - Anuruddha
@Date - 2025/02/11
 */

import 'package:adgo_mobile/modules/video_feed/data/repositories/video_repo.dart';
import 'package:adgo_mobile/modules/video_feed/model/video_model.dart';

abstract class IVideoService {
  final VideoRepository repository;

  IVideoService(this.repository);

  Future<List<VideoModel>> getchVideos();
  Future<bool> uploadVideo(VideoModel videoModel);
  Future<int> getAddCount();
  Future<bool> fetchMoreVideos(int currentAddsCount);
}