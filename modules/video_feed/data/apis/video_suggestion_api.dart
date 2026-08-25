import 'package:adgo_mobile/modules/video_feed/data/apis/ivideo_api.dart';
import 'package:adgo_mobile/modules/video_feed/model/video_model.dart';
import 'package:adgo_mobile/services/services/video_suggestion_service.dart';

class SuggestionVideoApi implements IVideoApi {
  final VideoSuggestionService _service;

  SuggestionVideoApi(this._service);

  List<VideoModel> _videoList = [];

  @override
  Future<List<VideoModel>> getVideos() async {
    print('======================Fetching videos from suggestion API==============================');
    final response = await _service.getAllVideos();
    print('======================Fetching over videos from suggestion API==============================');
    final data = response as List;

    print('======================Fetched ${data.length} videos from suggestion API==============================');

    print(data[0]);

    // TODO: Remove this filtering in production once all thumbnails are photos
    // Filter out video thumbnails during development
    final filteredData = data.where((e) {
      final thumbnail = e.thumbnail?.toString() ?? '';
      final isPhoto = _isPhotoThumbnail(thumbnail);
      
      if (!isPhoto) {
        print('🚫 API Filter: Rejecting reel with video thumbnail - ID: ${e.id}, Thumbnail: $thumbnail');
      }
      
      return isPhoto;
    }).toList();

    print('======================After filtering: ${filteredData.length}/${data.length} reels with photo thumbnails==============================');

    _videoList = filteredData.map((e) => VideoModel(
      id: e.id,
      title: e.title,
      thumbnail: e.thumbnail, // Photo thumbnail URL or path
      videoUrl: e.videoUrl,
    )).toList();

    return _videoList;
  }

  /// TODO: Remove this method in production
  /// Check if thumbnail is a photo (not video) - development safety check
  bool _isPhotoThumbnail(String thumbnailUrl) {
    if (thumbnailUrl.isEmpty) return false;
    
    final uri = Uri.tryParse(thumbnailUrl);
    if (uri == null) return false;
    
    String path = uri.path.toLowerCase();
    
    // Check for photo extensions
    final photoExtensions = ['.jpg', '.jpeg', '.png', '.webp', '.gif'];
    for (String ext in photoExtensions) {
      if (path.endsWith(ext)) {
        return true;
      }
    }
    
    // Check for video extensions (reject these)
    final videoExtensions = ['.mp4', '.avi', '.mov', '.mkv', '.webm', '.m4v'];
    for (String ext in videoExtensions) {
      if (path.endsWith(ext)) {
        return false;
      }
    }
    
    // URL pattern checks
    if (path.contains('image') || path.contains('img') || path.contains('photo')) {
      return true;
    }
    
    if (path.contains('video') || path.contains('vid') || path.contains('movie')) {
      return false;
    }
    
    // Default: if uncertain, reject to be safe during development
    return false;
  }

  @override
  Future<bool> uploadVideo(VideoModel video) async {
    _videoList = [..._videoList, video];
    return true;
  }

  @override
  Future<int> getAddCount() async {
    return _videoList.length;
  }

  @override
  Future<bool> fetchMoreVideos(int currentAddsCount) async {
    // Optional: Add pagination support here if backend supports it
    if (currentAddsCount >= 30) return false;

    // For now, simulate re-fetching or duplicating entries
    final more = await getVideos(); // Just reuse getVideos
    _videoList = [..._videoList, ...more];
    return true;
  }
}
