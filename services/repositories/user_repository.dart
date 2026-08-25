
/*
@Author - Anuruddha
@Date - 2025/05/09
 */


import 'package:adgo_mobile/services/models/ping_model.dart';
import 'package:dio/src/response.dart';
import '../services/user_service.dart';

class UserRepository {
  final UserService _authService = UserService();

  Future<void> login(String email, String password) async {
    final response = await _authService.login(email, password);
   
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
}) async {
  try {
    final response = await _authService.saveUser(
      userId: userId,
      userName: userName,
      email: email,
      shopId: shopId,
      dob: dob,
      gender: gender,
      profilePictureOBjectKey: profilePictureOBjectKey,
      state: state,
    );
    print(response);
    return response;

  } catch (e, stackTrace) {
    print("❌ Error in saveUser: $e");
    print("📌 Stacktrace: $stackTrace");
    rethrow;
  }
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
}) async {
  try {
    final response = await _authService.updateUser(
      userId: userId,
      userName: userName,
      email: email,
      shopId: shopId,
      dob: dob,
      gender: gender,
      profilePictureOBjectKey: profilePictureOBjectKey,
      state: state,
    );
    print("✅ User updated successfully: $response");
    return response;

  } catch (e, stackTrace) {
    print("❌ Error in updateUser: $e");
    print("📌 Stacktrace: $stackTrace");
    rethrow;
  }
}

  Future<PingModel> getPing() async {
    final response = await _authService.getPing();
     PingModel pingModel = PingModel(id: "1", name: response.data['pong'], description: response.data['pong']);
     return pingModel;
  }

  /// Get presigned upload URL for profile picture
  Future<Response> getProfilePicUploadUrl({
    required String userId,
    required String profilePicName,
  }) async {
    try {
      final response = await _authService.getProfilePicUploadUrl(
        userId: userId,
        profilePicName: profilePicName,
      );
      return response;
    } catch (e, stackTrace) {
      print("❌ Error in getProfilePicUploadUrl: $e");
      print("📌 Stacktrace: $stackTrace");
      rethrow;
    }
  }

  /// Get presigned download URL for profile picture
  Future<Response> getProfilePicDownloadUrl({
    required String userId,
    required String profilePicKey,
  }) async {
    try {
      final response = await _authService.getProfilePicDownloadUrl(
        userId: userId,
        profilePicKey: profilePicKey,
      );
      return response;
    } catch (e, stackTrace) {
      print("❌ Error in getProfilePicDownloadUrl: $e");
      print("📌 Stacktrace: $stackTrace");
      rethrow;
    }
  }

  /// Get user details by user IDs
  Future<Response> getUserByIds({
    required List<String> userIds,
    bool state = true,
  }) async {
    try {
      final response = await _authService.getUserByIds(
        userIds: userIds,
        state: state,
      );
      return response;
    } catch (e, stackTrace) {
      print("❌ Error in getUserByIds: $e");
      print("📌 Stacktrace: $stackTrace");
      rethrow;
    }
  }
}
