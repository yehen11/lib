
import 'package:adgo_mobile/modules/video_feed/data/apis/ivideo_api.dart';
import 'package:adgo_mobile/modules/video_feed/model/video_model.dart';

class MockVideoApi implements IVideoApi{

  
  MockVideoApi();

  @override
  Future<List<VideoModel>> getVideos() async {
  
  List<VideoModel> videoList = [];

  return videoList;
}

  @override
  Future<bool> uploadVideo(VideoModel videoModel) async{
    return true;
  }
  
  @override
  Future<int> getAddCount() async{
    return 0;
  }
  
  @override
  Future<bool> fetchMoreVideos(int currentAddsCount) async{
    return true;
  }

}
