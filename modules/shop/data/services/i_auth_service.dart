
/*
@Author - Anuruddha
@Date - 2025/03/08
*/

import 'package:adgo_mobile/modules/auth/data/repositories/auth_repo.dart';
import 'package:flutter/material.dart';

abstract class IAuthService {
  final AuthRepository repository;

  IAuthService(this.repository);

  Future<bool> signUpUser(String username,String password, BuildContext context);

  
  Future<bool> confirmSignUp(String username, String confirmationCode);

  Future<void> isUserSignedInWithEmail(String username);
 
  Future<bool> signInUser(String username, String password);

  
  Future<bool> signOut(String username);

  Future<bool> forgotPassword(String username);

  Future<bool> resetPassword(String username, String otp, String newPW);


  Future<bool> isUserSignedInSharedPref();

   Future<String?> getUserId(String email);

   Future<String?> signUpAndGetUserId(String email, String password);
 
}
