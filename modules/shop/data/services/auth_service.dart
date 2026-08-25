/*
@Author - Anuruddha
@Date - 2025/03/08
*/

import 'package:adgo_mobile/modules/auth/data/repositories/auth_repo.dart';
import 'package:adgo_mobile/modules/auth/data/services/i_auth_service.dart';
import 'package:flutter/material.dart';

class AuthService implements IAuthService {
  @override
  final AuthRepository repository;

  AuthService(this.repository);
  @override
  Future<bool> signUpUser(String username,String password, BuildContext context) async {
     return await repository.signUpUser(username, password, context);
  }

  @override
  Future<bool> confirmSignUp(String username, String confirmationCode) async {
     return await repository.confirmSignUp(username, confirmationCode);
  }

  @override
  Future<bool> isUserSignedInWithEmail(String username) async {
    return await repository.isUserSignedInWithEmail(username);
  }
  
  @override
  Future<bool> signInUser(String username, String password) async {
    return await repository.signInUser(username, password);
  }

  @override
  Future<bool> signOut(String username) async {
    return await repository.signOutUser(username);
  }

  

  @override
  Future<bool> resetPassword(String username, String otp, String newPW) async {
    return await repository.resetPassword(username, otp, newPW);
  }
  @override
  Future<bool> isUserSignedInSharedPref() async{
    return await repository.isUserSignedInSharedPref();
  }
  
  @override
  Future<bool> forgotPassword(String username) async{
    return await repository.forgotPassword(username);
  }
  @override
  Future<String?> getUserId(String email) async {
    return await repository.getUserId(email);
  }

  @override
  Future<String?> signUpAndGetUserId(String email, String password) async {
    return await repository.signUpAndGetUserId(email, password);
  }
}
