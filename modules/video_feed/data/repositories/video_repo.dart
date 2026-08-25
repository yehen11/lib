/*
@Author - Anuruddha
@Date - 2025/02/11
 */


import 'package:adgo_mobile/modules/video_feed/data/apis/ivideo_api.dart';
import 'package:adgo_mobile/modules/video_feed/model/video_model.dart';

class VideoRepository {
  final IVideoApi videoApi;

  VideoRepository(this.videoApi);

  Future<List<VideoModel>> getVideos() async {
    return await videoApi.getVideos(); 
  }

  Future<bool> uploadVideo(VideoModel video) async{
   return await videoApi.uploadVideo(video);
  } 

  Future<int> getAddCount() async{
   return await videoApi.getAddCount();
  }

  Future<bool> fetchMoreVideos(int currentAddsCount) async{
   return await videoApi.fetchMoreVideos(currentAddsCount);
  }
}
