import 'package:adgo_mobile/modules/video_feed/data/services/ivideo_service.dart';
import 'package:adgo_mobile/modules/video_feed/data/repositories/video_repo.dart';
import 'package:adgo_mobile/modules/video_feed/model/video_model.dart';

class VideoService implements IVideoService{

  @override
  final VideoRepository repository;

  VideoService(this.repository);

  @override
  Future<List<VideoModel>> getchVideos() async {
    return await repository.getVideos();
  }


 @override
  Future<bool> uploadVideo(VideoModel video) async{
   return await repository.uploadVideo(video);
  }
  
  @override
  Future<int> getAddCount() async{
    return await repository.getAddCount();
  }
  
  @override
  Future<bool> fetchMoreVideos(int currentAddsCount) async{
    return await repository.fetchMoreVideos(currentAddsCount);
  }

  

}
