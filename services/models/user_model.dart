/*
@Author - Anuruddha
@Date - 2025/05/09
 */

class UserModel {
  final String userId;
  final String userName;
  final String email;
  final String shopId;
  final DateTime dob;
  final String gender;
  final String profilePictureOBjectKey;
  final bool state;

  UserModel({
    required this.userId,
    required this.userName,
    required this.email,
    required this.shopId,
    required this.dob,
    required this.gender,
    required this.profilePictureOBjectKey,
    required this.state,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'],
      userName: json['userName'],
      email: json['email'],
      shopId: json['shopId'],
      dob: DateTime.parse(json['dob']),
      gender: json['gender'],
      profilePictureOBjectKey: json['profilePictureOBjectKey'],
      state: json['state'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'email': email,
      'shopId': shopId,
      'dob': dob.toIso8601String(),
      'gender': gender,
      'profilePictureOBjectKey': profilePictureOBjectKey,
      'state': state,
    };
  }
}
