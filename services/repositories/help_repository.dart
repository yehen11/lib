import 'package:adgo_mobile/services/core/api_client.dart';
import 'package:adgo_mobile/services/core/endpoints.dart';
import 'package:adgo_mobile/services/models/help_model.dart';
import 'package:dio/dio.dart';

class HelpRepository {
  final Dio _dio = ApiClient.dio;

  /// Fetch help and support information
  Future<HelpModel> getHelpInfo() async {
    try {
      final response = await _dio.get(Endpoints.helpSupport);
      return HelpModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch help information: $e');
    }
  }
}
