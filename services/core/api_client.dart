/*
@Author - Anuruddha
@Date - 2025/05/09
 */

import 'package:dio/dio.dart';
import 'dio_interceptors.dart';

class ApiClient {
  static final Dio dio = Dio(BaseOptions(
    //baseUrl: 'https://q3s4jm8wpb.execute-api.eu-north-1.amazonaws.com/prod',
    baseUrl : 'https://lyypt98p9g.execute-api.ap-south-1.amazonaws.com/prod',
    //  baseUrl : 'http://192.168.8.158:8080',
    //baseUrl: 'https://iky4lwun5h.execute-api.ap-south-1.amazonaws.com/prod',
    connectTimeout: const Duration(seconds: 100),
    receiveTimeout: const Duration(seconds: 100),
  ))..interceptors.add(DioInterceptors());
}
