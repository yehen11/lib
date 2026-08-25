/*
@Author - Anuruddha
@Date - 2025/05/09
 */

import 'package:dio/dio.dart';
//import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioInterceptors extends Interceptor {
 // final storage = const FlutterSecureStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    //final token = await storage.read(key: 'jwt');
    final token = "await storage.read(key: 'jwt')";
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }
}
