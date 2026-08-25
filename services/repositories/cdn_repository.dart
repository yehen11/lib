import 'package:dio/dio.dart';

import '../services/cdn_service.dart';

class CdnRepository {
  final CdnService _cdnService;

  CdnRepository(this._cdnService);

  /// Fetch CDN signed cookies
  Future<Response> getCdnCookies() async {
    try {
      return await _cdnService.getCdnCookies();
    } catch (e) {
      rethrow;
    }
  }
}
