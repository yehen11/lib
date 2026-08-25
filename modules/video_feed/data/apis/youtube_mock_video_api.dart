import 'package:adgo_mobile/modules/video_feed/data/apis/ivideo_api.dart';
import 'package:adgo_mobile/modules/video_feed/model/video_model.dart';

class YouTubeMockVideoApi implements IVideoApi{

  
  
  YouTubeMockVideoApi();

   List<VideoModel> videoList = [
    VideoModel(
      id: "1",
      thumbnail: "https://img.youtube.com/vi/3JZ_D3ELwOQ/0.jpg",
      videoUrl: "https://bucket-adgo.s3.ap-south-1.amazonaws.com/3s_9_16/clip_1.mp4", 
      title: "Test Video 1",
    ),
    VideoModel(
      id: "2",
      thumbnail: "https://img.youtube.com/vi/L_jWHffIx5E/0.jpg",
      videoUrl: "https://bucket-adgo.s3.ap-south-1.amazonaws.com/3s_9_16/clip_2.mp4",
      title: "Test Video 2",
    ),
    VideoModel(
      id: "3",
      thumbnail: "https://img.youtube.com/vi/L_jWHffIx5E/0.jpg",
      videoUrl: "https://bucket-adgo.s3.ap-south-1.amazonaws.com/3s_9_16/clip_3.mp4",
      title: "Test Video 3",
    ),
    VideoModel(
      id: "4",
      thumbnail: "https://img.youtube.com/vi/L_jWHffIx5E/0.jpg",
      videoUrl: "https://bucket-adgo.s3.ap-south-1.amazonaws.com/3s_9_16/clip_4.mp4",
      title: "Test Video 3",
    ),
    VideoModel(
      id: "5",
      thumbnail: "https://img.youtube.com/vi/L_jWHffIx5E/0.jpg",
      videoUrl: "https://bucket-adgo.s3.ap-south-1.amazonaws.com/3s_9_16/clip_5.mp4",
      title: "Test Video 3",
    ),
    VideoModel(
      id: "6",
      thumbnail: "https://img.youtube.com/vi/L_jWHffIx5E/0.jpg",
      videoUrl: "https://bucket-adgo.s3.ap-south-1.amazonaws.com/3s_9_16/clip_6.mp4",
      title: "Test Video 3",
    ),
    VideoModel(
      id: "7",
      thumbnail: "https://img.youtube.com/vi/L_jWHffIx5E/0.jpg",
      videoUrl: "https://bucket-adgo.s3.ap-south-1.amazonaws.com/3s_9_16/clip_7.mp4",
      title: "Test Video 3",
    ),
    VideoModel(
      id: "8",
      thumbnail: "https://img.youtube.com/vi/L_jWHffIx5E/0.jpg",
      videoUrl: "https://bucket-adgo.s3.ap-south-1.amazonaws.com/3s_9_16/clip_8.mp4",
      title: "Test Video 3",
    ),
    VideoModel(
      id: "9",
      thumbnail: "https://img.youtube.com/vi/L_jWHffIx5E/0.jpg",
      videoUrl: "https://bucket-adgo.s3.ap-south-1.amazonaws.com/3s_9_16/clip_9.mp4",
      title: "Test Video 3",
    ),
    VideoModel(
      id: "10",
      thumbnail: "https://img.youtube.com/vi/L_jWHffIx5E/0.jpg",
      videoUrl: "https://bucket-adgo.s3.ap-south-1.amazonaws.com/3s_9_16/clip_10.mp4",
      title: "Test Video 3",
    )
    
  ];

  @override
  Future<List<VideoModel>> getVideos() async {
  return videoList;
}

  @override
  Future<bool> uploadVideo(VideoModel video) async{
    videoList = [...videoList, video];
    return true;
  }
  
  @override
  Future<int> getAddCount() async{
    return videoList.length;
  }
  
  @override
Future<bool> fetchMoreVideos(int currentAddsCount) async{
   if(currentAddsCount >= 30)return false;

  List<VideoModel> newVideos = List.generate(1, (index) {
    int videoIndex = 0 + index;
    return VideoModel(
      id: videoIndex.toString(),
      thumbnail: "https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg",
      videoUrl: "https://bucket-adgo.s3.ap-south-1.amazonaws.com/3s_9_16/clip_2.mp4",
      title: "Fethced Video",
    );
  });


  videoList = [...videoList, ...newVideos];
  return true;
}

}
