import 'package:adgo_mobile/services/core/api_client.dart';
import 'package:adgo_mobile/services/core/endpoints.dart';
import 'package:dio/dio.dart';

class CdnService {
  final _dio = ApiClient.dio;

  /// Get CDN signed cookies
  Future<Response> getCdnCookies() {
    return _dio.get(Endpoints.getCdn);
  }
}
