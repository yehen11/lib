
/*
@Author - Anuruddha
@Date - 2025/05/09
 */

import 'package:adgo_mobile/services/core/api_client.dart';
import 'package:adgo_mobile/services/core/endpoints.dart';
import 'package:dio/dio.dart';


class UserService {
  final _dio = ApiClient.dio;

  Future<Response> login(String email, String password) {
    return _dio.post(Endpoints.login, data: {
      'email': email,
      'password': password,
    });
  }


  Future<Response> saveUser({
  required String userId,
  required String userName,
  required String email,
  required String shopId,
  required DateTime dob,
  required String gender,
  required String profilePictureOBjectKey,
  required bool state,
}) {
  return _dio.post(
    Endpoints.saveUser, 
    data: {
      'userId': userId,
      'userName': userName,
      'email': email,
      'shopId': shopId,
      'dob': dob.toUtc().toIso8601String(),
      'gender': gender,
      'profilePictureOBjectKey': profilePictureOBjectKey,
      'state': state,
    },
  );
}

/// Update existing user details
Future<Response> updateUser({
  required String userId,
  String? userName,
  String? email,
  String? shopId,
  DateTime? dob,
  String? gender,
  String? profilePictureOBjectKey,
  bool? state,
}) {
  // Build data map with only non-null values
  final Map<String, dynamic> data = {'userId': userId};
  
  if (userName != null) data['userName'] = userName;
  if (email != null) data['email'] = email;
  if (shopId != null) data['shopId'] = shopId;
  if (dob != null) data['dob'] = dob.toUtc().toIso8601String();
  if (gender != null) data['gender'] = gender;
  if (profilePictureOBjectKey != null) data['profilePictureOBjectKey'] = profilePictureOBjectKey;
  if (state != null) data['state'] = state;

  return _dio.post(
    Endpoints.updateUser,
    data: data,
  );
}


  Future<Response> getPing() {
    return _dio.get(Endpoints.ping);
  }

  /// Get presigned upload URL for profile picture
  Future<Response> getProfilePicUploadUrl({
    required String userId,
    required String profilePicName,
  }) {
    return _dio.get(
      Endpoints.getProfilePicUploadUrl,
      queryParameters: {
        'userID': userId,
        'profilePicName': profilePicName,
      },
    );
  }

  /// Get presigned download URL for profile picture
  Future<Response> getProfilePicDownloadUrl({
    required String userId,
    required String profilePicKey,
  }) {
    return _dio.get(
      Endpoints.getProfilePicDownloadUrl,
      queryParameters: {
        'userID': userId,
        'profilePicKey': profilePicKey,
      },
    );
  }

  /// Get user details by user IDs
  Future<Response> getUserByIds({
    required List<String> userIds,
    bool state = true,
  }) {
    return _dio.get(
      Endpoints.getUserByIds,
      queryParameters: {
        'userIds': userIds.join(','),
        'state': state.toString(),
      },
    );
  }
}
