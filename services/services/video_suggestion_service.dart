import 'dart:io';

import 'package:adgo_mobile/services/core/api_client.dart';
import 'package:adgo_mobile/services/core/endpoints.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../modules/video_feed/model/video_model.dart';

class VideoSuggestionService {
  final _dio = ApiClient.dio;

  List<VideoModel> _cachedVideoList = [];

  /// Clear all cached videos and downloaded files
  Future<void> clearCache() async {
    try {
      // Clear in-memory cache
      _cachedVideoList.clear();
      
      // Delete cached video files
      final dir = await getApplicationDocumentsDirectory();
      final downloadDir = Directory('${dir.path}/cached_videos');
      
      if (await downloadDir.exists()) {
        await downloadDir.delete(recursive: true);
        print('Cleared cached videos from disk');
      }
    } catch (e) {
      print('Error clearing video cache: $e');
    }
  }


  /// Get all uploaded videos
  Future<Response> getAllNetworkVideos() {
    print('======================Inside suggestion Service - getAllVideos() ==============================');
    return _dio.get(Endpoints.getAllVideos);

  }


  /// Get recommendations without user ID (v1)
  Future<Response> getV1Recommendations() {
    print('======================Inside suggestion Service - getV1Recommendations() ==============================');
    return _dio.get(Endpoints.getRecommendationsV1);
  }

  /// Get recommendations for a specific user (v2)
  Future<Response> getV2Recommendations(String userId) {
    print('======================Inside suggestion Service - getV2Recommendations() ==============================');
    return _dio.get(
      Endpoints.getRecommendationsV2,
      queryParameters: {
        'userId': userId,
      },
    );
  }


  /// Get all videos: Download & cache if needed, return cached list
  Future<List<VideoModel>> getAllVideos() async {
    print('======================Inside suggestion Service - getAllVideos() ==============================');
    await downloadAndCacheVideos();
    return _cachedVideoList;
  }

  /// Download and cache all videos locally
  Future<void> downloadAndCacheVideos() async {
    // Clear existing cache list to prevent showing stale data from previous user
    _cachedVideoList.clear();
    print("Cleared cached video list");
    
    final dir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory('${dir.path}/cached_videos');

    print("DownloadAndCacheVideos  Step 01 ===============");

    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }

    print("DownloadAndCacheVideos  Step 02 ===============");

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    
    if(userId == null) {
      print(" ==================== USER_ID is NULL ====================== ");
      print("Waiting for user to login before fetching videos...");
      // Return early - videos will be loaded when user logs in and provider is invalidated
      return;
    }
    
    print("USER_ID in video recomendation fetching =============== " + userId);

      // 1. Fetch all videos
     // final response = await getAllNetworkVideos();
      final response = await getV2Recommendations(userId);
      final data = response.data as List;


      List<VideoModel> _videoList = data.map((e) => VideoModel(
        id: e['videoId'],
        title: e['title'] ?? '',
        thumbnail: e['thumbnailUrl'] ?? '',
        videoUrl: e['videoUrl'] ?? '',
      )).toList();


      print("Videos  Size ===============  "+ _videoList.length.toString());

      if (_videoList.isEmpty) {
        print('No videos found to download.');
        return;
      }

      // 2. Iterate through each video entry
      for (final video in _videoList) {
        final key = video.thumbnail;

        print("thumbnailUrl  ===========   " + key);


          // 3. Get signed URL
          final signedUrlResponse = await _dio.get(
            Endpoints.getThumbnailDownloadUrl,
            queryParameters: {'thumbnailKey': key},
          );



          final signedUrl = signedUrlResponse.data;
          if (signedUrl == null) {
            print('Signed URL not found for videoKey: $key');
            continue;
          }


          print("signedUrl  ===========   " + signedUrl);

          final savePath = '${downloadDir.path}/$key';

          print("SAVE PATH ============ " + savePath);

          // 4. Skip if already downloaded
          if (File(savePath).existsSync()) {
            print('Video already cached: $key');
            _cachedVideoList.add(VideoModel(
              id: video.id,
              title: video.title,
              thumbnail: savePath, // LOCAL PATH
              videoUrl: video.videoUrl,
            ));
            continue;
          }

          print('Downloading video $key to $savePath');

        try {

          // 1. Make GET request
          final http.Response response = await http.get(Uri.parse(signedUrl));

          // 2. Check status
          if (response.statusCode == 200) {
            // 3. Write bytes to file
            final file = File(savePath);
            await file.writeAsBytes(response.bodyBytes);
            print('Downloaded and saved with http: $savePath');
          } else {
            print('Failed to download $key, status: ${response.statusCode}');
          }

          print('Downloaded and cached video: $key');

          // Add to cache list after successful download
          _cachedVideoList.add(VideoModel(
            id: video.id,
            title: video.title,
            thumbnail: savePath, // LOCAL PATH
            videoUrl: video.videoUrl,
          ));

          print('Downloaded and cached video: $key');
        } catch (e) {
          print('Error downloading video $key: $e');
        }
      }

  }



   /// Get video entries by IDs (optionally filtered by active/verified)
  Future<Response> getVideoEntriesByIds({
    required Set<String> videoIds,
    bool? active,
    bool? verified,
  }) {
    return _dio.get(
      Endpoints.getVideoEntriesByIds,
      queryParameters: {
        'videoIds': videoIds.toList(),
        if (active != null) 'active': active,
        if (verified != null) 'verified': verified,
      },
    );
  }

  /// Get videos by author (with optional filters)
  Future<Response> getVideoEntriesByAuthor({
    required String authorId,
    List<String>? videoIds,
    bool? active,
    bool? verified,
  }) {
    return _dio.get(
      Endpoints.getVideoEntriesByAuthor,
      queryParameters: {
        'authorId': authorId,
        if (videoIds != null) 'videoIds': videoIds,
        if (active != null) 'active': active,
        if (verified != null) 'verified': verified,
      },
    );
  }

  /// Get general video recommendations (v1)
  Future<Response> getRecommendationsV1() {
    return _dio.get(Endpoints.getRecommendationsV1);
  }

  /// Get user-specific video recommendations (v2)
  Future<Response> getRecommendationsV2(String userId) {
    return _dio.get(
      Endpoints.getRecommendationsV2,
      queryParameters: {'userId': userId},
    );
  }
  
}
