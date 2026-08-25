import 'package:flutter/material.dart';

abstract class IAuthApi {
  IAuthApi();

  Future<bool> signInUser(String email, String password);

  Future<bool> isUserSignedInWithEmail(String email);

  Future<bool> signUpUser(String email, String password, BuildContext context);

  Future<bool> confirmSignUp(String email, String otp);

  Future<bool> forgotPassword(String email);

  Future<bool> resetPassword(String email, String otp, String newPassword);

  Future<bool> signOutUser(String email);

  Future<bool> isUserSignedInSharedPref();

  Future<String?> getUserId(String email);

  Future<String?> signUpAndGetUserId(String email, String password);

}