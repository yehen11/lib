/*
@Author - Anuruddha
@Date - 2025/03/08
*/

import 'package:adgo_mobile/modules/auth/data/apis/i_auth_api.dart';
import 'package:flutter/material.dart';

class AuthRepository {
  final IAuthApi authApi;

  AuthRepository(this.authApi);

 
  Future<bool> signUpUser(String username, String password, BuildContext context) async {
     return await authApi.signUpUser(username, password, context);
  }


  Future<bool> isUserSignedInWithEmail(String username) async {
    return await authApi.isUserSignedInWithEmail(username);
  }
  
  Future<bool> confirmSignUp(String username, String confirmationCode) async {
     return await authApi.confirmSignUp(username, confirmationCode);
  }

  

  Future<bool> signInUser(String username, String password) async {
     return await authApi.signInUser(username, password);
  }

  
  Future<bool> signOutUser(String username) async {
    return await authApi.signOutUser(username);
  }

  Future<bool> forgotPassword(String username) async {
    return await authApi.forgotPassword(username);
  }
  
  Future<bool> resetPassword(String username, String otp, String newPW) async {
    return await authApi.resetPassword(username, otp, newPW);
  }

  Future<bool> isUserSignedInSharedPref()async{
    return await authApi.isUserSignedInSharedPref();
  }

  Future<String?> getUserId(String email) async {
    return await authApi.getUserId(email);
  }


  Future<String?> signUpAndGetUserId(String email, String password) async {
    return await authApi.signUpAndGetUserId(email, password);
  }


}
