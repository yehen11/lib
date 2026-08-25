import 'package:adgo_mobile/modules/reel_screen/data/apis/ireelapi.dart';
import 'package:adgo_mobile/modules/reel_screen/model/reel.dart';
import 'package:adgo_mobile/services/core/api_client.dart';
import 'package:adgo_mobile/services/core/endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReelApi implements IReelApi {
  final _dio = ApiClient.dio;

  @override
  Future<List<Reel>> getReels() async {
    try {
      // Get user ID from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        print('User ID is null, cannot fetch recommendations');
        return [];
      }

      print('Fetching recommendations for user: $userId');

      // Fetch recommendations from backend
      final response = await _dio.get(
        Endpoints.getRecommendationsV2,
        queryParameters: {'userId': userId},
      );

      final data = response.data as List;
      print('Fetched ${data.length} video recommendations');

      // Convert to Reel models with all available data
      final reels = data.map((e) => Reel(
        id: e['videoId'] ?? e['id'] ?? '',
        videoUrl: e['videoUrl'] ?? '',
        title: e['title'] ?? 'No title',
        shopId: e['shopId'] ?? '',
        shopHandle: e['shopHandle'] ?? '',
        description: e['description'] ?? '',

      )).toList();

      print('Converted to ${reels.length} reels');
      return reels;
    } catch (e) {
      print('Error fetching reels: $e');
      return [];
    }
  }
}
