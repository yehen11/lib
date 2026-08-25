import 'package:adgo_mobile/modules/reel_screen/data/apis/ireelapi.dart';
import 'package:adgo_mobile/modules/reel_screen/model/reel.dart';

class MockReelApi implements IReelApi{

  
  
  MockReelApi();

   List<Reel> reelsList = [
    Reel(
      id: "1",
      videoUrl:    "https://convert-videos.s3.ap-south-1.amazonaws.com/test/clip_1.mpd",//"https://convert-videos.s3.ap-south-1.amazonaws.com/test/clip_19.mpd",//"https://bucket-adgo.s3.ap-south-1.amazonaws.com/15s_dash/clip_5_manifest.mpd",//"https://livesim.dashif.org/livesim/chunkdur_1/ato_7/testpic4_8s/Manifest.mpd", 
      title: "Test Reel 1",
    ),
     Reel(
      id: "2",
      videoUrl: "https://convert-videos.s3.ap-south-1.amazonaws.com/test/clip_2.mpd", 
      title: "Test reel 2",
    ),
    Reel(
      id: "3",
      videoUrl: "https://convert-videos.s3.ap-south-1.amazonaws.com/test/clip_3.mpd", 
      title: "Test reel 3",
    ),
    Reel(
      id: "4",
      videoUrl: "https://convert-videos.s3.ap-south-1.amazonaws.com/test/clip_4.mpd", 
      title: "Test reel 4",
    ),
    
  ];


  @override
  Future<List<Reel>> getReels() async{
    return reelsList;
  }
  


}
